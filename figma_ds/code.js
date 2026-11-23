// DND Design System — плагин Figma.
//
// Задача: превратить `design_system.json` (экспорт из Dart-токенов) в реальную
// дизайн-систему внутри Figma: переменные, текстовые стили и компоненты,
// названные ровно так же, как Dart-виджеты.
//
// Ключевое ограничение: плагин НЕ генерирует экраны. Он создаёт детали, из
// которых ты собираешь макеты инстансами. Обратный путь (макет → Dart) идёт
// через REST: INSTANCE хранит componentId, по нему восстанавливается имя
// компонента, а имя — это имя нашего виджета.
//
// Все обращения к переменным и стилям обёрнуты в try/catch: на части планов
// Variables API может быть недоступен, и тогда плагин продолжает работу на
// сырых цветах, а не падает целиком.

const PAGE_NAME = 'DND Design System';
const KIT_PAGE_NAME = 'Flutter Kit';
const SCREENS_PAGE_NAME = 'Макеты';
const FONT_FAMILY = 'Inter';
const VAR_COLLECTION = 'DND / Tokens';
const TEXT_STYLE_PREFIX = 'AppTypography/';
const PREVIEW_CACHE_KEY = 'dnd.previews.v1';
const PREVIEW_CACHE_LIMIT = 400;

/** Предупреждения, которые не ломают сборку, но должны попасть в лог. */
let warnings = [];

/** Кеш PNG-превью по id компонента. Заполняется лениво из clientStorage. */
let previewCache = null;

/** Идущая автосборка: параллельные запросы библиотеки не должны её дублировать. */
let building = null;

figma.showUI(__html__, { width: 460, height: 620 });

figma.ui.onmessage = (msg) => {
  if (!msg || !msg.type) return;

  // Библиотека: UI просит список компонентов при открытии и по кнопке «Обновить».
  if (msg.type === 'library') {
    sendLibrary().catch((error) => {
      figma.ui.postMessage({ type: 'error', message: describe(error) });
    });
    return;
  }

  // Вставка инстанса: клик по карточке в библиотеке.
  if (msg.type === 'insert') {
    insertComponent(msg.nodeId)
      .then((result) => figma.ui.postMessage({ type: 'inserted', ...result }))
      .catch((error) => figma.ui.postMessage({ type: 'error', message: describe(error) }));
    return;
  }

  if (msg.type !== 'build') return;

  // Без файла собираем встроенную копию: UI не обязан знать, откуда данные.
  const payload = msg.payload || EMBEDDED_DESIGN_SYSTEM;

  if (!payload) {
    figma.ui.postMessage({
      type: 'error',
      message:
        'Нет данных для сборки: в code.js пустой блок embedded-design-system. ' +
        'Прогони `flutter test tool/export_design_system_test.dart` или выбери JSON.',
    });
    return;
  }

  warnings = [];
  run(payload)
    .then(async (summary) => {
      figma.ui.postMessage({ type: 'done', summary, warnings });
      try {
        figma.notify('DND Design System: готово');
      } catch (error) {
        /* notify есть не во всех сборках */
      }
      // После сборки библиотека должна обновиться сама.
      await sendLibrary();
    })
    .catch((error) => {
      figma.ui.postMessage({
        type: 'error',
        message: describe(error),
        warnings,
      });
    });
};

// --- основной сценарий -------------------------------------------------------

async function run(data) {
  validate(data);

  const colors = new Map(data.colors.map((c) => [c.name, c]));
  const typography = new Map(data.typography.map((t) => [t.name, t]));
  const radii = new Map(data.radii.map((r) => [r.name, r.value]));
  const spacing = new Map(data.spacing.map((s) => [s.name, s.value]));

  const page = await ensurePage(PAGE_NAME);
  await focusPage(page);
  clearPage(page);
  paintPage(page, colors.get('void0'));

  await loadFonts(data.typography);

  const variables = await buildVariables(data);
  const textStyles = await buildTextStyles(data, colors);

  const ctx = {
    colors,
    typography,
    radii,
    spacing,
    variables,
    textStyles,
    // Реестр имён: блоки (Scaffold, Form) вставляют инстансы уже собранных
    // компонентов. Без реестра пришлось бы копировать узлы, и связь с
    // компонентом терялась бы.
    registry: new Map(),
  };

  const components = await buildComponents(data.components, ctx);
  layOutComponents(components, data, ctx);

  const kit = await buildKit(data.kit, ctx);

  await ensureScreensPage(ctx);

  // Возвращаемся на страницу ДС: вьюпорт должен показать компоненты, а не артборд.
  await focusPage(page);

  try {
    figma.viewport.scrollAndZoomIntoView(components);
  } catch (error) {
    /* вьюпорт может быть недоступен в headless-режиме */
  }

  return {
    page: PAGE_NAME,
    components: components.length,
    kit: kit ? kit.components.length : 0,
    variables: variables.size,
    textStyles: textStyles.size,
    fonts: loadedFonts.size,
  };
}

// --- страницы ----------------------------------------------------------------

async function ensurePage(name) {
  await loadAllPages();

  const pages = figma.root.children;
  for (const page of pages) {
    if (page.name === name) return page;
  }

  const created = figma.createPage();
  created.name = name;
  return created;
}

async function ensureScreensPage(ctx) {
  const page = await ensurePage(SCREENS_PAGE_NAME);
  if (page.children.length > 0) return;

  await focusPage(page);
  paintPage(page, ctx.colors.get('void0'));

  const hint = makeText(
    'Подсказка',
    'Собирай экраны здесь: инстансы компонентов со страницы «' + PAGE_NAME + '».',
    'bodyMedium',
    'textSecondary',
    ctx,
  );
  hint.x = 64;
  hint.y = 40;

  const artboard = figma.createFrame();
  artboard.name = 'Экран / новый';
  artboard.resize(360, 800);
  artboard.fills = [solidPaint(ctx.colors.get('void0'))];
  artboard.x = 64;
  artboard.y = 96;
}

async function loadAllPages() {
  if (typeof figma.loadAllPagesAsync === 'function') {
    try {
      await figma.loadAllPagesAsync();
    } catch (error) {
      /* старый API не требует предзагрузки */
    }
  }
}

async function focusPage(page) {
  if (typeof figma.setCurrentPageAsync === 'function') {
    await figma.setCurrentPageAsync(page);
    return;
  }
  figma.currentPage = page;
}

/** Страница целиком принадлежит плагину: пересборка не оставляет дублей. */
function clearPage(page) {
  for (const child of page.children.slice()) {
    try {
      child.remove();
    } catch (error) {
      warnings.push('Не удалось удалить узел ' + child.name + ': ' + describe(error));
    }
  }
}

function paintPage(page, color) {
  if (!color) return;
  try {
    page.backgrounds = [solidPaint(color)];
  } catch (error) {
    /* фон страницы — косметика */
  }
}

// --- библиотека --------------------------------------------------------------

/**
 * Первый запуск без настройки: если служебных страниц нет или они пустые,
 * плагин собирает дизайн-систему сам из встроенной копии.
 *
 * Зачем: Plugin API не читает локальные файлы. Единственный способ доставить
 * токены — зашить JSON в `code.js`. Без этого каждый запуск начинается с
 * пустого каталога и ручного выбора файла, а «Собрать» недоступна, пока файл
 * не выбран. Это и был баг «плагин пустой».
 *
 * Пересборка не запускается, если компоненты уже есть: страницы принадлежат
 * плагину, но затирать их без команды нельзя.
 */
async function ensureBuilt() {
  if (building) {
    await building;
    return;
  }

  await loadAllPages();

  const countComponents = (page) =>
    page ? page.children.filter((node) => node.type === 'COMPONENT').length : 0;

  const built = countComponents(findPage(PAGE_NAME)) + countComponents(findPage(KIT_PAGE_NAME));
  if (built > 0 || !EMBEDDED_DESIGN_SYSTEM) return;

  building = (async () => {
    warnings = [];
    try {
      const summary = await run(EMBEDDED_DESIGN_SYSTEM);
      figma.ui.postMessage({ type: 'done', summary, warnings, auto: true });
    } catch (error) {
      figma.ui.postMessage({
        type: 'error',
        message: 'Автосборка не удалась: ' + describe(error),
      });
    }
  })();

  try {
    await building;
  } finally {
    building = null;
  }
}

/**
 * Каталог блоков для UI: наши виджеты + Material-kit.
 *
 * Список отдаётся сразу, превью — потоком. Экспорт 46 компонентов занимает
 * секунды; держать UI пустым это время нельзя. Кеш превью живёт в
 * `figma.clientStorage`: при повторном запуске карточки появляются с картинками
 * мгновенно, а после пересборки id меняются и кеш сам протухает.
 */
async function sendLibrary() {
  // Первый запуск: страниц нет — собираем сами, иначе каталог пустой.
  await ensureBuilt();
  await loadAllPages();

  const pages = [findPage(PAGE_NAME), findPage(KIT_PAGE_NAME)].filter(Boolean);
  const cache = await getPreviewCache();
  const items = [];

  for (const page of pages) {
    for (const node of page.children) {
      if (node.type !== 'COMPONENT') continue;

      items.push({
        id: node.id,
        name: node.name,
        group: node.getPluginData('group') || 'DND',
        description: node.description || '',
        dart: node.getPluginData('dart') || '',
        width: Math.round(node.width),
        height: Math.round(node.height),
        preview: cache[node.id] || null,
      });
    }
  }

  items.sort((a, b) => (a.group === b.group ? a.name.localeCompare(b.name) : a.group.localeCompare(b.group)));
  figma.ui.postMessage({ type: 'library', items, built: items.length > 0 });

  // Превью догоняют списком: UI уже отрисовал карточки-плейсхолдеры.
  sendPreviews(items).catch((error) => {
    figma.ui.postMessage({ type: 'error', message: describe(error) });
  });
}

/** Досылает PNG по одному: каждая карточка обновляется независимо. */
async function sendPreviews(items) {
  const cache = await getPreviewCache();
  const pending = items.filter((item) => !item.preview);
  if (pending.length === 0) return;

  let dirty = false;

  for (const item of pending) {
    const node = await getNode(item.id);
    if (!node || node.type !== 'COMPONENT') continue;

    try {
      const bytes = await node.exportAsync({
        format: 'PNG',
        constraint: { type: 'WIDTH', value: 320 },
      });
      const preview = figma.base64Encode(bytes);
      cache[item.id] = preview;
      dirty = true;
      figma.ui.postMessage({ type: 'preview', id: item.id, preview });
    } catch (error) {
      warnings.push('Превью не снято: ' + item.name);
    }
  }

  if (dirty) await savePreviewCache(cache);
}

async function getPreviewCache() {
  if (previewCache) return previewCache;

  previewCache = {};
  try {
    const stored = await figma.clientStorage.getAsync(PREVIEW_CACHE_KEY);
    if (stored && typeof stored === 'object') previewCache = stored;
  } catch (error) {
    /* кеш — ускорение, не источник правды */
  }

  return previewCache;
}

async function savePreviewCache(cache) {
  const keys = Object.keys(cache);
  // После каждой пересборки id новые: старые записи никто не удалит.
  if (keys.length > PREVIEW_CACHE_LIMIT) {
    previewCache = {};
    for (const key of keys.slice(-PREVIEW_CACHE_LIMIT)) previewCache[key] = cache[key];
  }

  try {
    await figma.clientStorage.setAsync(PREVIEW_CACHE_KEY, previewCache);
  } catch (error) {
    /* лимит хранилища — не повод падать */
  }
}

/** Клик по карточке: инстанс в центр вьюпорта, выделение и зум на него. */
async function insertComponent(nodeId) {
  const node = await getNode(nodeId);

  if (!node || node.type !== 'COMPONENT') {
    throw new Error('Компонент не найден. Пересобери дизайн-систему.');
  }

  const page = await insertTargetPage();
  const instance = node.createInstance();
  page.appendChild(instance);

  const center = figma.viewport.center;
  instance.x = Math.round(center.x - instance.width / 2);
  instance.y = Math.round(center.y - instance.height / 2);

  try {
    figma.currentPage.selection = [instance];
    figma.viewport.scrollAndZoomIntoView([instance]);
  } catch (error) {
    /* выделение — удобство, не обязательство */
  }

  return { name: node.name, page: page.name };
}

/** На служебных страницах вставлять нельзя: пересборка их очищает. */
async function insertTargetPage() {
  const name = figma.currentPage.name;
  if (name !== PAGE_NAME && name !== KIT_PAGE_NAME) return figma.currentPage;

  const page = await ensurePage(SCREENS_PAGE_NAME);
  await focusPage(page);
  return page;
}

function findPage(name) {
  for (const page of figma.root.children) {
    if (page.name === name) return page;
  }
  return null;
}

async function getNode(id) {
  if (typeof figma.getNodeByIdAsync === 'function') {
    return figma.getNodeByIdAsync(id);
  }
  return figma.getNodeById(id);
}

// --- шрифты ------------------------------------------------------------------

const loadedFonts = new Set();

/** Figma не знает числовых весов: 900 → Black, 600 → Semi Bold. */
function fontStyleFor(weight) {
  if (weight >= 900) return 'Black';
  if (weight >= 800) return 'ExtraBold';
  if (weight >= 700) return 'Bold';
  if (weight >= 600) return 'Semi Bold';
  if (weight >= 500) return 'Medium';
  if (weight >= 400) return 'Regular';
  return 'Light';
}

async function loadFonts(typography) {
  const styles = new Set(typography.map((t) => fontStyleFor(t.fontWeight)));
  styles.add('Regular');

  for (const style of styles) {
    const fontName = { family: FONT_FAMILY, style };
    try {
      await figma.loadFontAsync(fontName);
      loadedFonts.add(style);
    } catch (error) {
      warnings.push('Шрифт ' + FONT_FAMILY + ' ' + style + ' недоступен, беру Regular');
      try {
        await figma.loadFontAsync({ family: FONT_FAMILY, style: 'Regular' });
        loadedFonts.add('Regular');
      } catch (fallbackError) {
        warnings.push('Inter Regular тоже недоступен — тексты не созданы');
        return;
      }
    }
  }
}

function fontFor(weight) {
  const style = fontStyleFor(weight);
  return { family: FONT_FAMILY, style: loadedFonts.has(style) ? style : 'Regular' };
}

// --- переменные --------------------------------------------------------------

async function buildVariables(data) {
  const map = new Map();
  if (!figma.variables) {
    warnings.push('Variables API недоступен — цвета и отступы остались сырыми');
    return map;
  }

  try {
    const collections = await getCollections();
    // Копия, а не живой массив: удаление во время перебора пропускает элементы.
    for (const collection of collections.slice()) {
      if (collection.name !== VAR_COLLECTION) continue;
      try {
        collection.remove();
      } catch (error) {
        warnings.push('Старую коллекцию не удалить: ' + describe(error));
      }
    }

    const collection = figma.variables.createVariableCollection(VAR_COLLECTION);
    const modeId = collection.modes[0].modeId;

    for (const color of data.colors) {
      const variable = figma.variables.createVariable('color/' + color.name, collection, 'COLOR');
      variable.setValueForMode(modeId, rgba(color));
      map.set('color/' + color.name, variable);
    }

    for (const step of data.spacing) {
      const variable = figma.variables.createVariable('spacing/' + step.name, collection, 'FLOAT');
      variable.setValueForMode(modeId, step.value);
      map.set('spacing/' + step.name, variable);
    }

    for (const radius of data.radii) {
      const variable = figma.variables.createVariable('radius/' + radius.name, collection, 'FLOAT');
      variable.setValueForMode(modeId, radius.value);
      map.set('radius/' + radius.name, variable);
    }
  } catch (error) {
    warnings.push('Переменные не созданы: ' + describe(error));
  }

  return map;
}

async function getCollections() {
  if (typeof figma.variables.getLocalVariableCollectionsAsync === 'function') {
    return figma.variables.getLocalVariableCollectionsAsync();
  }
  return figma.variables.getLocalVariableCollections();
}

// --- текстовые стили ---------------------------------------------------------

async function buildTextStyles(data, colors) {
  const map = new Map();
  if (typeof figma.createTextStyle !== 'function') {
    warnings.push('Текстовые стили недоступны');
    return map;
  }

  try {
    const existing = await getTextStyles();
    // Копия, а не живой массив: удаление во время перебора пропускает элементы.
    for (const style of existing.slice()) {
      if (!style.name.startsWith(TEXT_STYLE_PREFIX)) continue;
      try {
        style.remove();
      } catch (error) {
        warnings.push('Старый стиль не удалить: ' + describe(error));
      }
    }

    for (const token of data.typography) {
      const style = figma.createTextStyle();
      style.name = TEXT_STYLE_PREFIX + token.name;
      style.fontName = fontFor(token.fontWeight);
      style.fontSize = token.fontSize;
      style.lineHeight = { unit: 'PIXELS', value: token.lineHeight };
      style.letterSpacing = { unit: 'PIXELS', value: token.letterSpacing };
      style.fills = [solidPaint(colors.get(token.color))];
      map.set(token.name, style);
    }
  } catch (error) {
    warnings.push('Текстовые стили не созданы: ' + describe(error));
  }

  return map;
}

async function getTextStyles() {
  if (typeof figma.getLocalTextStylesAsync === 'function') {
    return figma.getLocalTextStylesAsync();
  }
  return figma.getLocalTextStyles();
}

// --- компоненты --------------------------------------------------------------

async function buildComponents(specs, ctx) {
  const created = [];

  for (const spec of specs) {
    const node = figma.createComponent();
    node.name = spec.name;

    // Описание видно в Figma, путь к Dart-файлу читает библиотека плагина.
    try {
      node.description = spec.description || '';
      node.setPluginData('dart', spec.dart || '');
      node.setPluginData('group', 'DND');
    } catch (error) {
      warnings.push('Метаданные не записаны: ' + spec.name);
    }

    applyBox(node, spec, ctx);
    await appendChildren(node, spec.children || [], ctx);
    ctx.registry.set(spec.name, node);
    created.push(node);
  }

  return created;
}

/**
 * Страница Material-kit. Собирается тем же движком, что и наши компоненты:
 * отличие только в `group` и в том, что блоки тянут инстансы через реестр.
 */
async function buildKit(kit, ctx) {
  if (!kit || !Array.isArray(kit.groups) || kit.groups.length === 0) return null;

  const page = await ensurePage(kit.page || KIT_PAGE_NAME);
  await focusPage(page);
  clearPage(page);
  paintPage(page, ctx.colors.get('void0'));

  const created = [];

  for (const group of kit.groups) {
    for (const spec of group.items) {
      const node = figma.createComponent();
      node.name = spec.name;

      try {
        node.description = spec.description || '';
        node.setPluginData('dart', spec.dart || '');
        node.setPluginData('group', group.name);
      } catch (error) {
        warnings.push('Метаданные не записаны: ' + spec.name);
      }

      applyBox(node, spec, ctx);
      await appendChildren(node, spec.children || [], ctx);
      ctx.registry.set(spec.name, node);
      created.push({ node, group: group.name, spec });
    }
  }

  layOutKit(created, kit, ctx);
  return { page, components: created };
}

/** Общая часть для компонентов и фреймов: размер, заливка, обводка, auto-layout. */
function applyBox(node, spec, ctx) {
  const width = typeof spec.width === 'number' ? spec.width : 100;
  const height = typeof spec.height === 'number' ? spec.height : 100;
  node.resize(width, height);

  node.fills = spec.fill ? [paintFor(spec.fill, ctx)] : [];

  if (spec.stroke) {
    node.strokes = [paintFor(spec.stroke, ctx)];
    node.strokeWeight = typeof spec.strokeWidth === 'number' ? spec.strokeWidth : 1;
    try {
      node.strokeAlign = 'INSIDE';
    } catch (error) {
      /* свойство есть не у всех типов узлов */
    }
    if (Array.isArray(spec.strokeDash) && spec.strokeDash.length > 0) {
      try {
        node.dashPattern = spec.strokeDash;
      } catch (error) {
        warnings.push('Пунктир не применён на ' + node.name);
      }
    }
  } else {
    node.strokes = [];
  }

  const radius = spec.radius ? ctx.radii.get(spec.radius) : null;
  if (typeof radius === 'number') {
    try {
      node.cornerRadius = radius;
    } catch (error) {
      warnings.push('Радиус не применён на ' + node.name);
    }
  }

  if (spec.layout) applyLayout(node, spec, ctx);
}

function applyLayout(node, spec, ctx) {
  const layout = spec.layout;
  const horizontal = layout.mode === 'HORIZONTAL';

  node.layoutMode = horizontal ? 'HORIZONTAL' : 'VERTICAL';
  node.itemSpacing = typeof layout.spacing === 'number' ? layout.spacing : 0;

  const padding = spec.padding || {};
  node.paddingTop = padding.top || 0;
  node.paddingRight = padding.right || 0;
  node.paddingBottom = padding.bottom || 0;
  node.paddingLeft = padding.left || 0;

  node.primaryAxisAlignItems = layout.primaryAlign || 'MIN';
  node.counterAxisAlignItems = layout.counterAlign || 'MIN';

  // Ось: в горизонтальном layout ширина — primary, в вертикальном — height.
  const primaryHug = horizontal ? spec.hugWidth === true : spec.hugHeight === true;
  const counterHug = horizontal ? spec.hugHeight === true : spec.hugWidth === true;

  node.primaryAxisSizingMode = primaryHug ? 'AUTO' : 'FIXED';
  node.counterAxisSizingMode = counterHug ? 'AUTO' : 'FIXED';
}

async function appendChildren(parent, children, ctx) {
  for (const spec of children) {
    const child = await buildChild(spec, ctx);
    parent.appendChild(child);

    // FILL работает только внутри auto-layout, то есть после appendChild.
    if (spec.width === 'FILL') {
      try {
        child.layoutSizingHorizontal = 'FILL';
      } catch (error) {
        warnings.push('FILL не применён на ' + child.name);
      }

      // Текст с фиксированной шириной должен переноситься, а не обрезаться.
      if (child.type === 'TEXT') {
        try {
          child.textAutoResize = 'HEIGHT';
        } catch (error) {
          warnings.push('Перенос не включён на ' + child.name);
        }
      }
    }
  }
}

async function buildChild(spec, ctx) {
  if (spec.type === 'text') {
    const node = makeText(spec.name, spec.text, spec.style, spec.color, ctx);
    await applyTextStyle(node, spec.style, ctx);
    return node;
  }

  if (spec.type === 'instance') {
    return buildInstance(spec, ctx);
  }

  const node = figma.createFrame();
  node.name = spec.name;
  applyBox(node, spec, ctx);
  await appendChildren(node, spec.children || [], ctx);
  return node;
}

/**
 * Инстанс компонента по имени. Блоки (Scaffold, ListView, Form) обязаны
 * состоять из инстансов, а не из копий: иначе правка AppBar не доедет до
 * макетов, и обратный путь «инстанс → имя виджета» сломается.
 */
function buildInstance(spec, ctx) {
  const component = ctx.registry.get(spec.component);

  if (!component) {
    warnings.push('Блок «' + spec.component + '» не найден — вставлена заглушка');
    return figma.createFrame();
  }

  const instance = component.createInstance();
  instance.name = spec.name || component.name;

  if (typeof spec.height === 'number') {
    try {
      instance.resize(instance.width, spec.height);
    } catch (error) {
      /* инстанс с auto-layout может не принять размер */
    }
  }

  return instance;
}

function makeText(name, text, styleName, colorName, ctx) {
  const token = ctx.typography.get(styleName);
  const node = figma.createText();
  node.name = name;
  node.fontName = fontFor(token ? token.fontWeight : 400);

  // Ширина по содержимому: чип и подписи должны жаться, а не резать текст.
  try {
    node.textAutoResize = 'WIDTH_AND_HEIGHT';
  } catch (error) {
    /* свойство есть только у TEXT */
  }

  // characters строго после fontName: Figma падает, если шрифт не загружен.
  node.characters = text;

  if (token) {
    node.fontSize = token.fontSize;
    try {
      node.lineHeight = { unit: 'PIXELS', value: token.lineHeight };
      node.letterSpacing = { unit: 'PIXELS', value: token.letterSpacing };
    } catch (error) {
      /* интерлиньяж и трекинг — не критично */
    }
  }

  node.fills = [paintFor(colorName, ctx)];
  return node;
}

/** Стиль даёт размер и трекинг, цвет остаётся привязанным к переменной. */
async function applyTextStyle(node, styleName, ctx) {
  const style = ctx.textStyles.get(styleName);
  if (!style) return;

  try {
    if (typeof node.setTextStyleIdAsync === 'function') {
      await node.setTextStyleIdAsync(style.id);
    } else {
      node.textStyleId = style.id;
    }
  } catch (error) {
    warnings.push('Стиль ' + styleName + ' не привязан к тексту');
  }
}

function layOutComponents(components, data, ctx) {
  const header = makeText('DS · Заголовок', data.name, 'titleLarge', 'textPrimary', ctx);
  header.x = 64;
  header.y = 48;

  const subtitle = makeText(
    'DS · Подзаголовок',
    'Компоненты названы как Dart-виджеты. Экраны собирай инстансами на странице «' + SCREENS_PAGE_NAME + '».',
    'bodyMedium',
    'textSecondary',
    ctx,
  );
  subtitle.x = 64;
  subtitle.y = 84;

  let cursor = 64;
  const labelY = 132;
  const rowY = 164;
  const gap = 64;

  for (let index = 0; index < components.length; index += 1) {
    const component = components[index];
    const spec = data.components[index];

    const label = makeText('DS · ' + spec.name, spec.name, 'labelSmall', 'textMuted', ctx);
    label.x = cursor;
    label.y = labelY;

    component.x = cursor;
    component.y = rowY;

    cursor += component.width + gap;
  }
}

/** Раскладка kit-страницы: группы сверху вниз, внутри — сетка с подписями. */
function layOutKit(created, kit, ctx) {
  const startX = 64;
  const maxX = 1800;
  const labelOffset = 28;
  const columnGap = 64;
  const rowGap = 96;

  let y = 64;

  for (const group of kit.groups) {
    const header = makeText(
      'Kit · ' + group.name,
      group.name,
      'titleMedium',
      'textPrimary',
      ctx,
    );
    header.x = startX;
    header.y = y;

    y += labelOffset + 24;

    let x = startX;
    let rowHeight = 0;

    for (const spec of group.items) {
      const item = created.find((entry) => entry.spec === spec);
      if (!item) continue;

      const node = item.node;

      if (x > startX && x + node.width > maxX) {
        x = startX;
        y += rowHeight + rowGap;
        rowHeight = 0;
      }

      const label = makeText(
        'Kit · ' + spec.name,
        spec.name,
        'labelSmall',
        'textMuted',
        ctx,
      );
      label.x = x;
      label.y = y;

      node.x = x;
      node.y = y + labelOffset;

      rowHeight = Math.max(rowHeight, node.height + labelOffset);
      x += node.width + columnGap;
    }

    y += rowHeight + rowGap * 2;
  }
}

// --- краски ------------------------------------------------------------------

function hexToRgb(hex) {
  const clean = String(hex).replace('#', '');
  return {
    r: parseInt(clean.substring(0, 2), 16) / 255,
    g: parseInt(clean.substring(2, 4), 16) / 255,
    b: parseInt(clean.substring(4, 6), 16) / 255,
  };
}

function rgba(color) {
  const rgb = hexToRgb(color.hex);
  return { r: rgb.r, g: rgb.g, b: rgb.b, a: typeof color.alpha === 'number' ? color.alpha : 1 };
}

/**
 * Заливка/обводка по имени токена. Если переменная создана — привязываем её,
 * чтобы смена темы меняла макеты. Не создана — остаётся сырой цвет.
 */
function paintFor(tokenName, ctx) {
  const color = ctx.colors.get(tokenName);
  if (!color) {
    warnings.push('Неизвестный цвет: ' + tokenName);
    return { type: 'SOLID', color: { r: 1, g: 0, b: 1 } };
  }

  let paint = solidPaint(color);
  const variable = ctx.variables ? ctx.variables.get('color/' + tokenName) : null;

  if (variable && typeof figma.variables.setBoundVariableForPaint === 'function') {
    try {
      paint = figma.variables.setBoundVariableForPaint(paint, 'color', variable);
    } catch (error) {
      /* привязка — бонус, не обязательство */
    }
  }

  return paint;
}

function solidPaint(color) {
  const rgb = hexToRgb(color.hex);
  const alpha = typeof color.alpha === 'number' ? color.alpha : 1;
  const paint = { type: 'SOLID', color: rgb };
  if (alpha < 1) paint.opacity = alpha;
  return paint;
}

// --- служебное ---------------------------------------------------------------

function validate(data) {
  if (!data || typeof data !== 'object') throw new Error('Пустой JSON');
  const required = ['colors', 'spacing', 'radii', 'typography', 'components'];
  for (const key of required) {
    if (!Array.isArray(data[key])) throw new Error('В JSON нет массива «' + key + '»');
  }
  if (data.components.length === 0) throw new Error('В JSON нет компонентов');
}

function describe(error) {
  if (!error) return 'неизвестная ошибка';
  if (error.message) return error.message;
  return String(error);
}

// >>> embedded-design-system
// Блок генерируется `flutter test tool/export_design_system_test.dart`.
// Руками не править: при следующем экспорте содержимое перезапишется.
const EMBEDDED_DESIGN_SYSTEM = {"name":"DND Design System","version":1,"colors":[{"name":"void0","hex":"#000000","alpha":1.0,"argb":"FF000000"},{"name":"surface1","hex":"#09090B","alpha":1.0,"argb":"FF09090B"},{"name":"surface2","hex":"#121212","alpha":1.0,"argb":"FF121212"},{"name":"surface3","hex":"#1F1F23","alpha":1.0,"argb":"FF1F1F23"},{"name":"accent","hex":"#9880FF","alpha":1.0,"argb":"FF9880FF"},{"name":"accentSoft","hex":"#9880FF","alpha":0.1216,"argb":"1F9880FF"},{"name":"accentLine","hex":"#9880FF","alpha":0.4,"argb":"669880FF"},{"name":"textPrimary","hex":"#F4F4F5","alpha":1.0,"argb":"FFF4F4F5"},{"name":"textSecondary","hex":"#A1A1AA","alpha":1.0,"argb":"FFA1A1AA"},{"name":"textMuted","hex":"#71717A","alpha":1.0,"argb":"FF71717A"},{"name":"onAccent","hex":"#0A0612","alpha":1.0,"argb":"FF0A0612"},{"name":"divider","hex":"#FFFFFF","alpha":0.1216,"argb":"1FFFFFFF"},{"name":"border","hex":"#1F1F23","alpha":1.0,"argb":"FF1F1F23"},{"name":"error","hex":"#FF6B6B","alpha":1.0,"argb":"FFFF6B6B"},{"name":"success","hex":"#4ADE80","alpha":1.0,"argb":"FF4ADE80"}],"spacing":[{"name":"xxs","value":4.0},{"name":"xs","value":8.0},{"name":"sm","value":12.0},{"name":"md","value":16.0},{"name":"lg","value":20.0},{"name":"xl","value":24.0},{"name":"xxl","value":32.0},{"name":"xxxl","value":40.0},{"name":"huge","value":48.0},{"name":"massive","value":64.0}],"radii":[{"name":"sm","value":12.0},{"name":"md","value":16.0},{"name":"lg","value":24.0},{"name":"pill","value":999.0}],"typography":[{"name":"displayHero","fontFamily":"Inter","fontSize":72.0,"fontWeight":900,"lineHeight":72.0,"letterSpacing":-2.0,"color":"textPrimary"},{"name":"displayLarge","fontFamily":"Inter","fontSize":40.0,"fontWeight":900,"lineHeight":44.0,"letterSpacing":-1.0,"color":"textPrimary"},{"name":"displayMedium","fontFamily":"Inter","fontSize":32.0,"fontWeight":900,"lineHeight":36.0,"letterSpacing":-0.5,"color":"textPrimary"},{"name":"headlineMedium","fontFamily":"Inter","fontSize":24.0,"fontWeight":800,"lineHeight":28.0,"letterSpacing":-0.3,"color":"textPrimary"},{"name":"titleLarge","fontFamily":"Inter","fontSize":20.0,"fontWeight":700,"lineHeight":24.0,"letterSpacing":-0.2,"color":"textPrimary"},{"name":"titleMedium","fontFamily":"Inter","fontSize":16.0,"fontWeight":600,"lineHeight":20.0,"letterSpacing":0,"color":"textPrimary"},{"name":"bodyLarge","fontFamily":"Inter","fontSize":15.0,"fontWeight":400,"lineHeight":22.0,"letterSpacing":0,"color":"textPrimary"},{"name":"bodyMedium","fontFamily":"Inter","fontSize":14.0,"fontWeight":400,"lineHeight":20.0,"letterSpacing":0,"color":"textSecondary"},{"name":"labelLarge","fontFamily":"Inter","fontSize":15.0,"fontWeight":600,"lineHeight":16.0,"letterSpacing":0.2,"color":"onAccent"},{"name":"labelSmall","fontFamily":"Inter","fontSize":11.0,"fontWeight":600,"lineHeight":14.0,"letterSpacing":0.6,"color":"textMuted"}],"components":[{"name":"RollButton","dart":"lib/widgets/roll_button.dart","description":"Основное действие экрана: полная ширина, 56 px.","width":320,"height":56,"fill":"accent","radius":"md","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"padding":{"top":0.0,"right":16.0,"bottom":0.0,"left":16.0},"children":[{"type":"text","name":"Label","text":"Бросить","style":"titleMedium","color":"onAccent"}]},{"name":"DiceChip/Default","dart":"lib/widgets/dice_selector.dart","description":"Чип выбора кубика, невыбранный.","height":40,"hugWidth":true,"stroke":"divider","strokeWidth":0.5,"radius":"pill","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"padding":{"top":0.0,"right":16.0,"bottom":0.0,"left":16.0},"children":[{"type":"text","name":"Label","text":"D20","style":"labelLarge","color":"textSecondary"}]},{"name":"DiceChip/Selected","dart":"lib/widgets/dice_selector.dart","description":"Чип выбора кубика, выбранный.","height":40,"hugWidth":true,"fill":"accentSoft","stroke":"accentLine","strokeWidth":0.5,"radius":"pill","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"padding":{"top":0.0,"right":16.0,"bottom":0.0,"left":16.0},"children":[{"type":"text","name":"Label","text":"D20","style":"labelLarge","color":"accent"}]},{"name":"CountStepper","dart":"lib/widgets/count_stepper.dart","description":"Счётчик количества: − значение +, в одной рамке.","width":320,"height":56,"fill":"surface1","stroke":"divider","strokeWidth":0.5,"radius":"md","layout":{"mode":"HORIZONTAL","primaryAlign":"MIN","counterAlign":"CENTER","spacing":0.0},"padding":{"top":0.0,"right":0.0,"bottom":0.0,"left":0.0},"children":[{"type":"frame","name":"Decrement","width":56,"height":56,"radius":"md","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"text","name":"Glyph","text":"−","style":"titleLarge","color":"textSecondary"}]},{"type":"frame","name":"Value","width":"FILL","height":56,"layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"text","name":"Count","text":"1","style":"titleLarge","color":"textPrimary"}]},{"type":"frame","name":"Increment","width":56,"height":56,"radius":"md","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"text","name":"Glyph","text":"+","style":"titleLarge","color":"textSecondary"}]}]},{"name":"SurfaceCard","dart":"lib/theme/app_theme.dart","description":"Карточка: surface1, radius md, обводка divider, padding 20.","width":320,"hugHeight":true,"fill":"surface1","stroke":"divider","strokeWidth":0.5,"radius":"md","layout":{"mode":"VERTICAL","primaryAlign":"MIN","counterAlign":"MIN","spacing":12.0},"padding":{"top":20.0,"right":20.0,"bottom":20.0,"left":20.0},"children":[{"type":"text","name":"Title","text":"Заголовок","style":"titleMedium","color":"textPrimary","width":"FILL"},{"type":"text","name":"Body","text":"Описание в две строки — проверка переноса.","style":"bodyMedium","color":"textSecondary","width":"FILL"}]},{"name":"DiceShape","dart":"lib/widgets/dice_shape.dart","description":"Кубик 200×200. Форма рисуется кодом, здесь placeholder.","width":200,"height":200,"stroke":"border","strokeWidth":1,"strokeDash":[4.0,4.0],"radius":"lg","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"padding":{"top":0.0,"right":0.0,"bottom":0.0,"left":0.0},"children":[{"type":"text","name":"Result","text":"20","style":"displayHero","color":"textPrimary"}]}],"kit":{"page":"Flutter Kit","groups":[{"name":"Buttons","items":[{"name":"FilledButton","description":"Основное действие. Accent-заливка, pill, высота 40.","dart":"FilledButton({required VoidCallback? onPressed, required Widget child})","height":40.0,"fill":"accent","radius":"pill","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"padding":{"top":0.0,"right":24.0,"bottom":0.0,"left":24.0},"children":[{"type":"text","name":"Label","text":"Кнопка","style":"labelLarge","color":"onAccent"}],"hugWidth":true},{"name":"FilledButton / tonal","description":"Второстепенное действие. AccentSoft вместо accent.","dart":"FilledButton.tonal({required VoidCallback? onPressed, required Widget child})","height":40.0,"fill":"accentSoft","radius":"pill","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"padding":{"top":0.0,"right":24.0,"bottom":0.0,"left":24.0},"children":[{"type":"text","name":"Label","text":"Кнопка","style":"labelLarge","color":"accent"}],"hugWidth":true},{"name":"ElevatedButton","description":"Кнопка с приподнятой поверхностью. Тень не используем — стиль плоский.","dart":"ElevatedButton({required VoidCallback? onPressed, required Widget child})","height":40.0,"fill":"surface3","radius":"pill","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"padding":{"top":0.0,"right":24.0,"bottom":0.0,"left":24.0},"children":[{"type":"text","name":"Label","text":"Кнопка","style":"labelLarge","color":"accent"}],"hugWidth":true},{"name":"OutlinedButton","description":"Кнопка-контур. Обводка border, заливки нет.","dart":"OutlinedButton({required VoidCallback? onPressed, required Widget child})","height":40.0,"stroke":"border","strokeWidth":0.5,"radius":"pill","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"padding":{"top":0.0,"right":24.0,"bottom":0.0,"left":24.0},"children":[{"type":"text","name":"Label","text":"Кнопка","style":"labelLarge","color":"accent"}],"hugWidth":true},{"name":"TextButton","description":"Текстовая кнопка. Без рамки и заливки.","dart":"TextButton({required VoidCallback? onPressed, required Widget child})","height":40.0,"radius":"pill","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"padding":{"top":0.0,"right":16.0,"bottom":0.0,"left":16.0},"children":[{"type":"text","name":"Label","text":"Кнопка","style":"labelLarge","color":"accent"}],"hugWidth":true},{"name":"IconButton","description":"Квадратная кнопка 40×40 с иконкой.","dart":"IconButton({required VoidCallback? onPressed, required Widget icon})","width":40.0,"height":40.0,"radius":"pill","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"frame","name":"Icon","width":24.0,"height":24.0,"fill":"surface3","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"text","name":"Glyph","text":"+","style":"labelSmall","color":"textPrimary"}]}]},{"name":"FloatingActionButton","description":"Плавающая кнопка 56×56, radius md.","dart":"FloatingActionButton({required VoidCallback? onPressed, required Widget child})","width":56.0,"height":56.0,"fill":"accent","radius":"md","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"text","name":"Icon","text":"+","style":"titleLarge","color":"onAccent"}]},{"name":"SegmentedButton","description":"Переключатель из трёх сегментов в общей рамке.","dart":"SegmentedButton<T>({required List<ButtonSegment<T>> segments, required Set<T> selected})","width":320.0,"height":40.0,"stroke":"border","strokeWidth":0.5,"radius":"pill","layout":{"mode":"HORIZONTAL","primaryAlign":"MIN","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"frame","name":"Day","width":"FILL","height":40.0,"fill":"accentSoft","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"text","name":"Label","text":"День","style":"labelLarge","color":"accent"}]},{"type":"frame","name":"Week","width":"FILL","height":40.0,"layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"text","name":"Label","text":"Неделя","style":"labelLarge","color":"textSecondary"}]},{"type":"frame","name":"Month","width":"FILL","height":40.0,"layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"text","name":"Label","text":"Месяц","style":"labelLarge","color":"textSecondary"}]}]}]},{"name":"Selection","items":[{"name":"Checkbox","description":"Флажок 22×22 с галочкой.","dart":"Checkbox({required bool? value, required ValueChanged<bool?>? onChanged})","width":22.0,"height":22.0,"fill":"accent","radius":"sm","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"text","name":"Glyph","text":"✓","style":"labelSmall","color":"onAccent"}]},{"name":"Radio","description":"Переключатель 20×20: кольцо accent и точка внутри.","dart":"Radio<T>({required T value, required T? groupValue, required ValueChanged<T?>? onChanged})","width":20.0,"height":20.0,"stroke":"accent","strokeWidth":2.0,"radius":"pill","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"frame","name":"Dot","width":8.0,"height":8.0,"fill":"accent","radius":"pill"}]},{"name":"Switch","description":"Тумблер 52×32, включён.","dart":"Switch({required bool value, required ValueChanged<bool>? onChanged})","width":52.0,"height":32.0,"fill":"accent","radius":"pill","layout":{"mode":"HORIZONTAL","primaryAlign":"MAX","counterAlign":"CENTER","spacing":0.0},"padding":{"top":4.0,"right":4.0,"bottom":4.0,"left":4.0},"children":[{"type":"frame","name":"Thumb","width":24.0,"height":24.0,"fill":"onAccent","radius":"pill"}]},{"name":"Slider","description":"Ползунок: трек 4 px и бегунок 20×20 на 40 %.","dart":"Slider({required double value, required ValueChanged<double>? onChanged})","width":320.0,"height":40.0,"layout":{"mode":"HORIZONTAL","primaryAlign":"MIN","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"frame","name":"Track","width":"FILL","height":4.0,"fill":"surface3","radius":"pill"},{"type":"frame","name":"Thumb","width":20.0,"height":20.0,"fill":"accent","radius":"pill"}]}]},{"name":"Chips","items":[{"name":"Chip","description":"Чип-метка. Контур divider, высота 32.","dart":"Chip({required Widget label})","height":32.0,"stroke":"divider","strokeWidth":0.5,"radius":"sm","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"padding":{"top":0.0,"right":16.0,"bottom":0.0,"left":16.0},"children":[{"type":"text","name":"Label","text":"Метка","style":"labelSmall","color":"textSecondary"}],"hugWidth":true},{"name":"FilterChip","description":"Выбранный фильтр: accentSoft, галочка, accent-текст.","dart":"FilterChip({required Widget label, required bool selected, required ValueChanged<bool>? onSelected})","height":32.0,"fill":"accentSoft","stroke":"accentLine","strokeWidth":0.5,"radius":"sm","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"padding":{"top":0.0,"right":16.0,"bottom":0.0,"left":16.0},"children":[{"type":"text","name":"Glyph","text":"✓","style":"labelSmall","color":"accent"},{"type":"text","name":"Label","text":"Фильтр","style":"labelSmall","color":"accent"}],"hugWidth":true},{"name":"ChoiceChip","description":"Одиночный выбор из набора. Заливка surface2.","dart":"ChoiceChip({required Widget label, required bool selected, required ValueChanged<bool>? onSelected})","height":32.0,"fill":"surface2","radius":"sm","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"padding":{"top":0.0,"right":16.0,"bottom":0.0,"left":16.0},"children":[{"type":"text","name":"Label","text":"Выбор","style":"labelSmall","color":"textPrimary"}],"hugWidth":true}]},{"name":"Inputs","items":[{"name":"TextField","description":"Поле ввода 56 px: surface1, контур divider, radius md.","dart":"TextField({TextEditingController? controller, String? hintText, InputDecoration? decoration})","width":320.0,"height":56.0,"fill":"surface1","stroke":"divider","strokeWidth":0.5,"radius":"md","layout":{"mode":"HORIZONTAL","primaryAlign":"MIN","counterAlign":"CENTER","spacing":0.0},"padding":{"top":0.0,"right":16.0,"bottom":0.0,"left":16.0},"children":[{"type":"text","name":"Hint","text":"Введите значение","style":"bodyMedium","color":"textMuted"}]},{"name":"TextField / filled","description":"Заполненное поле без контура: surface2.","dart":"TextField({InputDecoration? decoration}) // filled: true","width":320.0,"height":56.0,"fill":"surface2","radius":"md","layout":{"mode":"HORIZONTAL","primaryAlign":"MIN","counterAlign":"CENTER","spacing":0.0},"padding":{"top":0.0,"right":16.0,"bottom":0.0,"left":16.0},"children":[{"type":"text","name":"Hint","text":"Введите значение","style":"bodyMedium","color":"textMuted"}]},{"name":"SearchBar","description":"Поиск: pill-поле с иконкой.","dart":"SearchBar({required SearchController controller, String? hintText})","width":320.0,"height":56.0,"fill":"surface2","radius":"pill","layout":{"mode":"HORIZONTAL","primaryAlign":"MIN","counterAlign":"CENTER","spacing":0.0},"padding":{"top":0.0,"right":16.0,"bottom":0.0,"left":16.0},"children":[{"type":"frame","name":"Icon","width":20.0,"height":20.0,"fill":"surface3","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"text","name":"Glyph","text":"?","style":"labelSmall","color":"textMuted"}]},{"type":"text","name":"Hint","text":"Поиск","style":"bodyMedium","color":"textMuted"}]},{"name":"DropdownMenu","description":"Выпадающий список: поле и шеврон справа.","dart":"DropdownMenu<T>({required List<DropdownMenuEntry<T>> dropdownMenuEntries})","width":320.0,"height":56.0,"fill":"surface1","stroke":"divider","strokeWidth":0.5,"radius":"md","layout":{"mode":"HORIZONTAL","primaryAlign":"MIN","counterAlign":"CENTER","spacing":0.0},"padding":{"top":0.0,"right":16.0,"bottom":0.0,"left":16.0},"children":[{"type":"text","name":"Value","text":"Значение","style":"bodyMedium","color":"textPrimary"},{"type":"frame","name":"Spacer","width":"FILL","height":1.0},{"type":"text","name":"Chevron","text":"v","style":"labelSmall","color":"textMuted"}]}]},{"name":"Surfaces","items":[{"name":"Card","description":"Карточка: surface1, radius md, padding 20, hug по высоте.","dart":"Card({required Widget child})","width":320.0,"fill":"surface1","stroke":"divider","strokeWidth":0.5,"radius":"md","layout":{"mode":"VERTICAL","primaryAlign":"MIN","counterAlign":"MIN","spacing":12.0},"padding":{"top":20.0,"right":20.0,"bottom":20.0,"left":20.0},"children":[{"type":"text","name":"Title","text":"Заголовок","style":"titleMedium","color":"textPrimary","width":"FILL"},{"type":"text","name":"Body","text":"Описание в две строки — проверка переноса.","style":"bodyMedium","color":"textSecondary","width":"FILL"}],"hugHeight":true},{"name":"ListTile","description":"Строка списка 72 px: аватар, заголовок, подпись, шеврон.","dart":"ListTile({Widget? leading, required Widget title, Widget? subtitle, Widget? trailing})","width":320.0,"height":72.0,"layout":{"mode":"HORIZONTAL","primaryAlign":"MIN","counterAlign":"CENTER","spacing":12.0},"padding":{"top":0.0,"right":16.0,"bottom":0.0,"left":16.0},"children":[{"type":"frame","name":"Leading","width":40.0,"height":40.0,"fill":"surface3","radius":"pill","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"text","name":"Initial","text":"D","style":"labelLarge","color":"textSecondary"}]},{"type":"frame","name":"Text","width":"FILL","layout":{"mode":"VERTICAL","primaryAlign":"CENTER","counterAlign":"MIN","spacing":0.0},"children":[{"type":"text","name":"Title","text":"Заголовок","style":"titleMedium","color":"textPrimary"},{"type":"text","name":"Subtitle","text":"Подпись","style":"bodyMedium","color":"textSecondary"}]},{"type":"text","name":"Trailing","text":"›","style":"titleLarge","color":"textMuted"}]},{"name":"Divider","description":"Линия-разделитель на всю ширину.","dart":"Divider({double height = 16, double thickness = 1})","width":320.0,"height":1.0,"fill":"divider"},{"name":"Badge","description":"Счётчик-бейдж 24×24 на accent.","dart":"Badge({required Widget label})","width":24.0,"height":24.0,"fill":"accent","radius":"pill","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"text","name":"Label","text":"3","style":"labelSmall","color":"onAccent"}]},{"name":"Tooltip","description":"Всплывающая подсказка: surface3, radius sm.","dart":"Tooltip({required String message, required Widget child})","height":36.0,"fill":"surface3","radius":"sm","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"padding":{"top":0.0,"right":12.0,"bottom":0.0,"left":12.0},"children":[{"type":"text","name":"Message","text":"Подсказка","style":"labelSmall","color":"textPrimary"}],"hugWidth":true}]},{"name":"Navigation","items":[{"name":"AppBar","description":"Верхняя панель 64 px: заголовок и два действия.","dart":"AppBar({Widget? title, List<Widget>? actions})","width":360.0,"height":64.0,"fill":"surface1","layout":{"mode":"HORIZONTAL","primaryAlign":"SPACE_BETWEEN","counterAlign":"CENTER","spacing":12.0},"padding":{"top":0.0,"right":16.0,"bottom":0.0,"left":16.0},"children":[{"type":"text","name":"Title","text":"Экран","style":"titleMedium","color":"textPrimary"},{"type":"frame","name":"Actions","layout":{"mode":"HORIZONTAL","primaryAlign":"MIN","counterAlign":"CENTER","spacing":12.0},"children":[{"type":"frame","name":"First","width":24.0,"height":24.0,"fill":"surface3","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"text","name":"Glyph","text":"×","style":"labelSmall","color":"textSecondary"}]},{"type":"frame","name":"Second","width":24.0,"height":24.0,"fill":"surface3","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"text","name":"Glyph","text":"+","style":"labelSmall","color":"textSecondary"}]}]}]},{"name":"NavigationBar","description":"Нижняя навигация 80 px: три пункта, активный первый.","dart":"NavigationBar({required List<Widget> destinations, required int selectedIndex})","width":360.0,"height":96.0,"fill":"surface1","layout":{"mode":"HORIZONTAL","primaryAlign":"MIN","counterAlign":"CENTER","spacing":0.0},"padding":{"top":8.0,"right":0.0,"bottom":8.0,"left":0.0},"children":[{"type":"frame","name":"Dice","width":"FILL","layout":{"mode":"VERTICAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":4.0},"children":[{"type":"frame","name":"Icon","width":24.0,"height":24.0,"fill":"accentSoft","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"text","name":"Glyph","text":"•","style":"labelSmall","color":"accent"}]},{"type":"text","name":"Label","text":"Кубики","style":"labelSmall","color":"accent"}]},{"type":"frame","name":"Sheets","width":"FILL","layout":{"mode":"VERTICAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":4.0},"children":[{"type":"frame","name":"Icon","width":24.0,"height":24.0,"layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"text","name":"Glyph","text":"•","style":"labelSmall","color":"textMuted"}]},{"type":"text","name":"Label","text":"Листы","style":"labelSmall","color":"textMuted"}]},{"type":"frame","name":"Rules","width":"FILL","layout":{"mode":"VERTICAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":4.0},"children":[{"type":"frame","name":"Icon","width":24.0,"height":24.0,"layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"text","name":"Glyph","text":"•","style":"labelSmall","color":"textMuted"}]},{"type":"text","name":"Label","text":"Правила","style":"labelSmall","color":"textMuted"}]}]},{"name":"NavigationRail","description":"Боковая навигация 80 px: те же пункты, вертикально.","dart":"NavigationRail({required List<NavigationRailDestination> destinations, required int selectedIndex})","width":80.0,"height":240.0,"fill":"surface1","layout":{"mode":"VERTICAL","primaryAlign":"MIN","counterAlign":"CENTER","spacing":16.0},"padding":{"top":16.0,"right":0.0,"bottom":16.0,"left":0.0},"children":[{"type":"frame","name":"Dice","layout":{"mode":"VERTICAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":4.0},"children":[{"type":"frame","name":"Icon","width":24.0,"height":24.0,"fill":"accentSoft","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"text","name":"Glyph","text":"•","style":"labelSmall","color":"accent"}]},{"type":"text","name":"Label","text":"Кубики","style":"labelSmall","color":"accent"}]},{"type":"frame","name":"Sheets","layout":{"mode":"VERTICAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":4.0},"children":[{"type":"frame","name":"Icon","width":24.0,"height":24.0,"layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"text","name":"Glyph","text":"•","style":"labelSmall","color":"textMuted"}]},{"type":"text","name":"Label","text":"Листы","style":"labelSmall","color":"textMuted"}]},{"type":"frame","name":"Rules","layout":{"mode":"VERTICAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":4.0},"children":[{"type":"frame","name":"Icon","width":24.0,"height":24.0,"layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"text","name":"Glyph","text":"•","style":"labelSmall","color":"textMuted"}]},{"type":"text","name":"Label","text":"Правила","style":"labelSmall","color":"textMuted"}]}]},{"name":"TabBar","description":"Табы: активный accent с подчёркиванием.","dart":"TabBar({required List<Widget> tabs, required TabController controller})","width":360.0,"height":48.0,"layout":{"mode":"HORIZONTAL","primaryAlign":"MIN","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"frame","name":"First","width":"FILL","height":48.0,"layout":{"mode":"VERTICAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"text","name":"Label","text":"Первый","style":"labelLarge","color":"accent"},{"type":"frame","name":"Indicator","width":32.0,"height":2.0,"fill":"accent"}]},{"type":"frame","name":"Second","width":"FILL","height":48.0,"layout":{"mode":"VERTICAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"text","name":"Label","text":"Второй","style":"labelLarge","color":"textSecondary"},{"type":"frame","name":"Indicator","width":32.0,"height":2.0}]},{"type":"frame","name":"Third","width":"FILL","height":48.0,"layout":{"mode":"VERTICAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"text","name":"Label","text":"Третий","style":"labelLarge","color":"textSecondary"},{"type":"frame","name":"Indicator","width":32.0,"height":2.0}]}]},{"name":"Drawer","description":"Боковое меню 320 px: заголовок и четыре пункта.","dart":"Drawer({required Widget child})","width":320.0,"height":360.0,"fill":"surface1","layout":{"mode":"VERTICAL","primaryAlign":"MIN","counterAlign":"MIN","spacing":8.0},"padding":{"top":20.0,"right":20.0,"bottom":20.0,"left":20.0},"children":[{"type":"text","name":"Header","text":"D&D","style":"titleLarge","color":"textPrimary"},{"type":"text","name":"First","text":"Кубики","style":"bodyLarge","color":"textSecondary"},{"type":"text","name":"Second","text":"Листы персонажа","style":"bodyLarge","color":"textSecondary"},{"type":"text","name":"Third","text":"Правила","style":"bodyLarge","color":"textSecondary"},{"type":"text","name":"Fourth","text":"Настройки","style":"bodyLarge","color":"textSecondary"}]}]},{"name":"Dialogs","items":[{"name":"AlertDialog","description":"Модальное окно: surface2, radius lg, две кнопки.","dart":"AlertDialog({Widget? title, Widget? content, List<Widget>? actions})","width":320.0,"fill":"surface2","radius":"lg","layout":{"mode":"VERTICAL","primaryAlign":"MIN","counterAlign":"MIN","spacing":12.0},"padding":{"top":20.0,"right":20.0,"bottom":20.0,"left":20.0},"children":[{"type":"text","name":"Title","text":"Заголовок","style":"titleMedium","color":"textPrimary","width":"FILL"},{"type":"text","name":"Content","text":"Текст диалога в две строки.","style":"bodyMedium","color":"textSecondary","width":"FILL"},{"type":"frame","name":"Actions","width":"FILL","layout":{"mode":"HORIZONTAL","primaryAlign":"MAX","counterAlign":"CENTER","spacing":8.0},"children":[{"type":"instance","name":"Cancel","component":"TextButton"},{"type":"instance","name":"Confirm","component":"FilledButton"}]}],"hugHeight":true},{"name":"BottomSheet","description":"Нижний лист: ручка, заголовок, текст. Скруглены верхние углы.","dart":"showModalBottomSheet<T>({required BuildContext context, required WidgetBuilder builder})","width":360.0,"fill":"surface2","radius":"lg","layout":{"mode":"VERTICAL","primaryAlign":"MIN","counterAlign":"CENTER","spacing":12.0},"padding":{"top":12.0,"right":20.0,"bottom":20.0,"left":20.0},"children":[{"type":"frame","name":"Handle","width":40.0,"height":4.0,"fill":"border","radius":"pill"},{"type":"text","name":"Title","text":"Заголовок листа","style":"titleMedium","color":"textPrimary"},{"type":"text","name":"Body","text":"Содержимое листа.","style":"bodyMedium","color":"textSecondary"}],"hugHeight":true},{"name":"SnackBar","description":"Уведомление 56 px внизу экрана.","dart":"SnackBar({required Widget content, SnackBarAction? action})","width":360.0,"height":56.0,"fill":"surface3","radius":"sm","layout":{"mode":"HORIZONTAL","primaryAlign":"SPACE_BETWEEN","counterAlign":"CENTER","spacing":12.0},"padding":{"top":0.0,"right":16.0,"bottom":0.0,"left":16.0},"children":[{"type":"text","name":"Content","text":"Кубик брошен","style":"bodyMedium","color":"textPrimary"},{"type":"text","name":"Action","text":"Отмена","style":"labelLarge","color":"accent"}]},{"name":"MaterialBanner","description":"Плашка на всю ширину: текст и две кнопки.","dart":"MaterialBanner({required Widget content, required List<Widget> actions})","width":360.0,"fill":"surface2","stroke":"divider","strokeWidth":0.5,"radius":"sm","layout":{"mode":"VERTICAL","primaryAlign":"MIN","counterAlign":"MIN","spacing":12.0},"padding":{"top":16.0,"right":16.0,"bottom":16.0,"left":16.0},"children":[{"type":"text","name":"Content","text":"Проверь характеристики.","style":"bodyMedium","color":"textSecondary","width":"FILL"},{"type":"frame","name":"Actions","width":"FILL","layout":{"mode":"HORIZONTAL","primaryAlign":"MAX","counterAlign":"CENTER","spacing":8.0},"children":[{"type":"instance","name":"Dismiss","component":"TextButton"},{"type":"instance","name":"Confirm","component":"FilledButton"}]}],"hugHeight":true}]},{"name":"Progress","items":[{"name":"LinearProgressIndicator","description":"Линейный прогресс 4 px, заполнен на 40 %.","dart":"LinearProgressIndicator({double? value})","width":320.0,"height":4.0,"fill":"surface3","radius":"pill","children":[{"type":"frame","name":"Value","width":128.0,"height":4.0,"fill":"accent","radius":"pill"}]},{"name":"CircularProgressIndicator","description":"Круговой прогресс: кольцо accent 3 px.","dart":"CircularProgressIndicator({double? value, double strokeWidth = 4})","width":40.0,"height":40.0,"stroke":"accent","strokeWidth":3.0,"radius":"pill"}]},{"name":"Data","items":[{"name":"DataTable","description":"Таблица: заголовок и две строки по три колонки.","dart":"DataTable({required List<DataColumn> columns, required List<DataRow> rows})","width":320.0,"fill":"surface1","stroke":"divider","strokeWidth":0.5,"radius":"md","layout":{"mode":"VERTICAL","primaryAlign":"MIN","counterAlign":"MIN","spacing":0.0},"children":[{"type":"frame","name":"Header","width":"FILL","layout":{"mode":"HORIZONTAL","primaryAlign":"MIN","counterAlign":"CENTER","spacing":12.0},"padding":{"top":8.0,"right":12.0,"bottom":8.0,"left":12.0},"children":[{"type":"text","name":"First","text":"Имя","style":"labelSmall","color":"textMuted","width":"FILL"},{"type":"text","name":"Second","text":"КД","style":"labelSmall","color":"textMuted"},{"type":"text","name":"Third","text":"ХП","style":"labelSmall","color":"textMuted"}]},{"type":"frame","name":"Divider","width":"FILL","height":1.0,"fill":"divider"},{"type":"frame","name":"Row1","width":"FILL","layout":{"mode":"HORIZONTAL","primaryAlign":"MIN","counterAlign":"CENTER","spacing":12.0},"padding":{"top":8.0,"right":12.0,"bottom":8.0,"left":12.0},"children":[{"type":"text","name":"First","text":"Гоблин","style":"bodyMedium","color":"textPrimary","width":"FILL"},{"type":"text","name":"Second","text":"15","style":"bodyMedium","color":"textPrimary"},{"type":"text","name":"Third","text":"7","style":"bodyMedium","color":"textPrimary"}]},{"type":"frame","name":"Divider","width":"FILL","height":1.0,"fill":"divider"},{"type":"frame","name":"Row2","width":"FILL","layout":{"mode":"HORIZONTAL","primaryAlign":"MIN","counterAlign":"CENTER","spacing":12.0},"padding":{"top":8.0,"right":12.0,"bottom":8.0,"left":12.0},"children":[{"type":"text","name":"First","text":"Орк","style":"bodyMedium","color":"textPrimary","width":"FILL"},{"type":"text","name":"Second","text":"13","style":"bodyMedium","color":"textPrimary"},{"type":"text","name":"Third","text":"15","style":"bodyMedium","color":"textPrimary"}]}],"hugHeight":true}]},{"name":"Blocks","items":[{"name":"Scaffold","description":"Каркас экрана 360×640: AppBar и тело.","dart":"Scaffold({AppBar? appBar, required Widget body})","width":360.0,"height":640.0,"fill":"void0","layout":{"mode":"VERTICAL","primaryAlign":"MIN","counterAlign":"MIN","spacing":0.0},"children":[{"type":"instance","name":"AppBar","component":"AppBar","width":"FILL"},{"type":"frame","name":"Body","width":"FILL","layout":{"mode":"VERTICAL","primaryAlign":"MIN","counterAlign":"MIN","spacing":16.0},"padding":{"top":16.0,"right":16.0,"bottom":16.0,"left":16.0},"children":[{"type":"text","name":"Placeholder","text":"Содержимое экрана","style":"bodyMedium","color":"textSecondary"}]}]},{"name":"ListView","description":"Список: три строки ListTile подряд.","dart":"ListView({required List<Widget> children})","width":360.0,"fill":"void0","layout":{"mode":"VERTICAL","primaryAlign":"MIN","counterAlign":"MIN","spacing":0.0},"children":[{"type":"instance","name":"First","component":"ListTile","width":"FILL"},{"type":"frame","name":"Divider","width":"FILL","height":1.0,"fill":"divider"},{"type":"instance","name":"Second","component":"ListTile","width":"FILL"},{"type":"frame","name":"Divider","width":"FILL","height":1.0,"fill":"divider"},{"type":"instance","name":"Third","component":"ListTile","width":"FILL"}],"hugHeight":true},{"name":"Form","description":"Форма: два поля и кнопка отправки.","dart":"Form({required GlobalKey<FormState> key, required Widget child})","width":360.0,"fill":"void0","layout":{"mode":"VERTICAL","primaryAlign":"MIN","counterAlign":"MIN","spacing":16.0},"padding":{"top":16.0,"right":16.0,"bottom":16.0,"left":16.0},"children":[{"type":"instance","name":"Name","component":"TextField","width":"FILL"},{"type":"instance","name":"Class","component":"DropdownMenu","width":"FILL"},{"type":"instance","name":"Submit","component":"FilledButton"}],"hugHeight":true},{"name":"EmptyState","description":"Пустое состояние: иконка, заголовок, текст, кнопка.","dart":"EmptyState({required Widget icon, required String title, required String message, required VoidCallback onAction})","width":320.0,"layout":{"mode":"VERTICAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":12.0},"padding":{"top":24.0,"right":24.0,"bottom":24.0,"left":24.0},"children":[{"type":"frame","name":"Icon","width":64.0,"height":64.0,"fill":"surface3","layout":{"mode":"HORIZONTAL","primaryAlign":"CENTER","counterAlign":"CENTER","spacing":0.0},"children":[{"type":"text","name":"Glyph","text":"?","style":"labelSmall","color":"textPrimary"}]},{"type":"text","name":"Title","text":"Пока пусто","style":"titleMedium","color":"textPrimary"},{"type":"text","name":"Message","text":"Здесь появятся сохранённые персонажи.","style":"bodyMedium","color":"textSecondary","width":"FILL"},{"type":"instance","name":"Action","component":"FilledButton"}],"hugHeight":true}]}]}};
// <<< embedded-design-system
