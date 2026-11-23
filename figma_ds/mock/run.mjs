// Mock-харнесс для figma_ds/code.js.
//
// Figma Plugin API нельзя запустить без Figma. Этот скрипт поднимает заглушку
// ровно с теми методами, которые использует плагин, и проверяет результат:
// страницы, компоненты, размеры, auto-layout, переменные, стили.
//
// Запуск: `node figma_ds/mock/run.mjs`
// Код возврата 1 — плагин сломан, 0 — контракт соблюдён.

import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import vm from 'node:vm';

const here = dirname(fileURLToPath(import.meta.url));
const pluginDir = join(here, '..');
const data = JSON.parse(readFileSync(join(pluginDir, 'design_system.json'), 'utf8'));
const source = readFileSync(join(pluginDir, 'code.js'), 'utf8');

// Второй сценарий: сборка Figma без Variables API. Плагин обязан выжить
// на сырых цветах и честно предупредить, а не упасть.
const noVariables = process.argv.includes('--no-variables');

const INTER_STYLES = new Set([
  'Thin',
  'ExtraLight',
  'Light',
  'Regular',
  'Medium',
  'Semi Bold',
  'Bold',
  'ExtraBold',
  'Black',
]);

// --- заглушка узлов ----------------------------------------------------------

let nextId = 1;

function makeNode(type, extra = {}) {
  const node = {
    id: `${nextId}:${nextId++}`,
    type,
    name: '',
    children: [],
    parent: null,
    x: 0,
    y: 0,
    width: 0,
    height: 0,
    fills: [],
    strokes: [],
    effects: [],
    backgrounds: [],
    cornerRadius: 0,
    strokeWeight: 0,
    strokeAlign: 'INSIDE',
    dashPattern: [],
    layoutMode: 'NONE',
    itemSpacing: 0,
    paddingTop: 0,
    paddingRight: 0,
    paddingBottom: 0,
    paddingLeft: 0,
    primaryAxisSizingMode: 'FIXED',
    counterAxisSizingMode: 'FIXED',
    primaryAxisAlignItems: 'MIN',
    counterAxisAlignItems: 'MIN',
    layoutSizingHorizontal: 'FIXED',
    fontName: null,
    fontSize: 0,
    lineHeight: null,
    letterSpacing: null,
    characters: '',
    textStyleId: null,
    textAutoResize: 'NONE',

    appendChild(child) {
      if (child.parent) {
        child.parent.children = child.parent.children.filter((item) => item !== child);
      }
      child.parent = node;
      node.children.push(child);
      return child;
    },
    resize(width, height) {
      node.width = width;
      node.height = height;
    },
    remove() {
      if (node.parent) {
        node.parent.children = node.parent.children.filter((item) => item !== node);
      }
      node.removed = true;
    },
    async setTextStyleIdAsync(id) {
      node.textStyleId = id;
    },
    description: '',
    pluginData: {},
    getPluginData(key) {
      return node.pluginData[key] || '';
    },
    setPluginData(key, value) {
      node.pluginData[key] = value;
    },
    async exportAsync() {
      // Валидный PNG-заголовок: содержимое не важно, важен факт экспорта.
      return new Uint8Array([137, 80, 78, 71, 13, 10, 26, 10]);
    },
    createInstance() {
      const instance = makeNode('INSTANCE', {
        name: node.name,
        componentId: node.id,
        width: node.width,
        height: node.height,
      });
      figma.currentPage.appendChild(instance);
      return instance;
    },
    ...extra,
  };

  return node;
}

function makePage(name) {
  return makeNode('PAGE', { name, selection: [] });
}

/** В Figma createFrame/createText/createComponent сразу кладут узел на текущую страницу. */
function attach(node) {
  figma.currentPage.appendChild(node);
  return node;
}

/** Поиск узла по id по всем страницам — как figma.getNodeByIdAsync. */
function findNode(id) {
  const stack = [...pages];
  while (stack.length > 0) {
    const node = stack.pop();
    if (node.id === id) return node;
    stack.push(...node.children);
  }
  return null;
}

// --- заглушка figma ----------------------------------------------------------

const pages = [makePage('Page 1')];
const messages = [];
const notifications = [];
const loadedFonts = new Set();
const collections = [];
const variables = [];
const textStyles = [];

function variableCollection(name) {
  const collection = {
    id: `collection:${collections.length + 1}`,
    name,
    modes: [{ modeId: 'mode:1', name: 'Default' }],
    variableIds: [],
    remove() {
      const index = collections.indexOf(collection);
      if (index >= 0) collections.splice(index, 1);
      // В Figma переменные умирают вместе с коллекцией — повторяем поведение.
      for (const id of collection.variableIds) {
        const at = variables.findIndex((variable) => variable.id === id);
        if (at >= 0) variables.splice(at, 1);
      }
    },
  };
  collections.push(collection);
  return collection;
}

const figma = {
  root: { children: pages, name: 'Mock file' },
  currentPage: pages[0],
  ui: {
    onmessage: null,
    postMessage(message) {
      messages.push(message);
    },
  },
  viewport: {
    center: { x: 480, y: 360 },
    scrollAndZoomIntoView() {},
  },
  showUI() {},
  notify(message) {
    notifications.push(message);
  },
  closePlugin() {},
  base64Encode(bytes) {
    return Buffer.from(bytes).toString('base64');
  },
  clientStorage: {
    store: new Map(),
    async getAsync(key) {
      return this.store.has(key) ? this.store.get(key) : undefined;
    },
    async setAsync(key, value) {
      this.store.set(key, value);
    },
  },
  async getNodeByIdAsync(id) {
    return findNode(id);
  },
  getNodeById(id) {
    return findNode(id);
  },

  async loadAllPagesAsync() {},
  async setCurrentPageAsync(page) {
    figma.currentPage = page;
  },
  createPage() {
    const page = makePage(`Page ${pages.length + 1}`);
    pages.push(page);
    return page;
  },
  createFrame() {
    return attach(makeNode('FRAME'));
  },
  createComponent() {
    return attach(makeNode('COMPONENT'));
  },
  createText() {
    return attach(makeNode('TEXT'));
  },
  createRectangle() {
    return attach(makeNode('RECTANGLE'));
  },
  createTextStyle() {
    const style = {
      id: `style:${textStyles.length + 1}`,
      name: '',
      fontName: null,
      fontSize: 0,
      lineHeight: null,
      letterSpacing: null,
      fills: [],
      remove() {
        const index = textStyles.indexOf(style);
        if (index >= 0) textStyles.splice(index, 1);
      },
    };
    textStyles.push(style);
    return style;
  },
  async getLocalTextStylesAsync() {
    return textStyles;
  },
  async loadFontAsync(font) {
    if (font.family !== 'Inter' || !INTER_STYLES.has(font.style)) {
      throw new Error(`Шрифт ${font.family} ${font.style} не найден`);
    }
    loadedFonts.add(`${font.family} ${font.style}`);
  },

  variables: {
    async getLocalVariableCollectionsAsync() {
      return collections;
    },
    createVariableCollection(name) {
      return variableCollection(name);
    },
    createVariable(name, collection, resolvedType) {
      const variable = {
        id: `variable:${variables.length + 1}`,
        name,
        resolvedType,
        values: {},
        setValueForMode(modeId, value) {
          variable.values[modeId] = value;
        },
      };
      variables.push(variable);
      collection.variableIds.push(variable.id);
      return variable;
    },
    setBoundVariableForPaint(paint, field, variable) {
      return { ...paint, boundVariables: { [field]: { type: 'VARIABLE_ALIAS', id: variable.id } } };
    },
  },
};

if (noVariables) delete figma.variables;

// --- запуск плагина ----------------------------------------------------------

const sandbox = {
  figma,
  __html__: '<html lang="ru"></html>',
  console,
};
vm.createContext(sandbox);
vm.runInContext(source, sandbox, { filename: 'code.js' });

if (typeof figma.ui.onmessage !== 'function') {
  fail('Плагин не подписался на figma.ui.onmessage');
}

// Встроенная копия обязана совпадать с design_system.json: её пишет экспортёр,
// и расхождение означает, что плагин собирает устаревшие токены.
const embedded = vm.runInContext('EMBEDDED_DESIGN_SYSTEM', sandbox);
check(
  JSON.stringify(embedded) === JSON.stringify(data),
  'встроенная ДС в code.js совпадает с design_system.json',
);

const totalComponents =
  data.components.length + data.kit.groups.reduce((sum, group) => sum + group.items.length, 0);

// 1. Пустой документ: плагин обязан собраться сам, без файла и без кнопки.
figma.ui.onmessage({ type: 'library' });
const auto = await waitFor(['done', 'error']);

if (auto.type === 'error') {
  console.error('Автосборка вернула ошибку: ' + auto.message);
  process.exit(1);
}

check(auto.auto === true, 'первый запуск: сборка запущена автоматически');

const autoLibrary = await waitFor(['library']);
check(
  autoLibrary.items.length === totalComponents,
  `автосборка: ${totalComponents} карточек, получено ${autoLibrary.items.length}`,
);

// Превью автосборки нужно дождаться: следующий шаг пересоберёт страницы, и
// параллельный экспорт по старым id не должен с ним пересекаться.
await waitForPreviews(totalComponents);

// 2. Явная сборка с payload: пересборка не плодит дубли и работает как раньше.
messages.length = 0;
figma.ui.onmessage({ type: 'build', payload: data });
const result = await waitFor(['done', 'error']);

if (result.type === 'error') {
  console.error('Плагин вернул ошибку: ' + result.message);
  process.exit(1);
}

// --- проверки ----------------------------------------------------------------

const problems = [];
const warnings = result.warnings || [];

const dsPage = pages.find((page) => page.name === 'DND Design System');
const screensPage = pages.find((page) => page.name === 'Макеты');
const components = dsPage ? dsPage.children.filter((node) => node.type === 'COMPONENT') : [];
const texts = dsPage ? dsPage.children.filter((node) => node.type === 'TEXT') : [];

check(dsPage, 'страница «DND Design System» создана');
check(screensPage, 'страница «Макеты» создана');
check(components.length === data.components.length, `компонентов ${data.components.length}, получено ${components.length}`);
check(texts.length === data.components.length + 2, `подписей ${data.components.length + 2}, получено ${texts.length}`);

const expectedVariables = data.colors.length + data.spacing.length + data.radii.length;

if (noVariables) {
  check(variables.length === 0, 'без Variables API переменные не создаются');
  check(
    warnings.some((warning) => warning.includes('Variables API недоступен')),
    'без Variables API плагин предупреждает',
  );
} else {
  check(variables.length === expectedVariables, `переменных ${expectedVariables}, получено ${variables.length}`);
  check(collections.length === 1, 'коллекция переменных одна');
}

check(textStyles.length === data.typography.length, `текстовых стилей ${data.typography.length}, получено ${textStyles.length}`);
check(loadedFonts.size === 5, `шрифтов загружено 5, получено ${loadedFonts.size}`);

for (const spec of data.components) {
  const component = components.find((node) => node.name === spec.name);
  check(component, `компонент «${spec.name}» существует`);
  if (!component) continue;

  if (typeof spec.width === 'number' && typeof spec.height === 'number') {
    check(
      component.width === spec.width && component.height === spec.height,
      `«${spec.name}» ${spec.width}×${spec.height}, получено ${component.width}×${component.height}`,
    );
  }

  const horizontal = !spec.layout || spec.layout.mode === 'HORIZONTAL';

  if (spec.hugWidth) {
    const mode = horizontal ? component.primaryAxisSizingMode : component.counterAxisSizingMode;
    check(mode === 'AUTO', `«${spec.name}» тянется по ширине (AUTO)`);
  }

  if (spec.hugHeight) {
    const mode = horizontal ? component.counterAxisSizingMode : component.primaryAxisSizingMode;
    check(mode === 'AUTO', `«${spec.name}» тянется по высоте (AUTO)`);
  }

  check(component.children.length === (spec.children || []).length, `«${spec.name}»: детей ${(spec.children || []).length}, получено ${component.children.length}`);

  if (spec.fill) {
    const paint = component.fills[0];
    check(paint && paint.type === 'SOLID', `«${spec.name}» залит`);
    if (!noVariables) {
      check(
        paint && paint.boundVariables && paint.boundVariables.color,
        `«${spec.name}»: заливка привязана к переменной`,
      );
    }
  }

  if (spec.stroke) {
    check(component.strokes.length === 1, `«${spec.name}»: обводка есть`);
    check(component.strokeWeight === spec.strokeWidth, `«${spec.name}»: толщина обводки ${spec.strokeWidth}`);
  }

  if (Array.isArray(spec.strokeDash)) {
    check(
      JSON.stringify(component.dashPattern) === JSON.stringify(spec.strokeDash),
      `«${spec.name}»: пунктир ${spec.strokeDash.join('/')}`,
    );
  }
}

const stepper = components.find((node) => node.name === 'CountStepper');
if (stepper) {
  check(stepper.children.length === 3, 'CountStepper: три зоны');
  const middle = stepper.children[1];
  check(middle && middle.name === 'Value', 'CountStepper: центр — Value');
  check(middle && middle.layoutSizingHorizontal === 'FILL', 'CountStepper: центр тянется по ширине');
}

const card = components.find((node) => node.name === 'SurfaceCard');
if (card) {
  const body = card.children.find((child) => child.name === 'Body');
  check(body && body.layoutSizingHorizontal === 'FILL', 'SurfaceCard: Body тянется по ширине');
  check(body && body.textAutoResize === 'HEIGHT', 'SurfaceCard: Body переносится по высоте');
}

const textStylesNamed = textStyles.map((style) => style.name).sort();
const expectedStyles = data.typography.map((token) => `AppTypography/${token.name}`).sort();
check(
  JSON.stringify(textStylesNamed) === JSON.stringify(expectedStyles),
  'имена текстовых стилей совпадают с токенами',
);

const variableNames = variables.map((variable) => variable.name);
if (!noVariables) {
  check(variableNames.includes('color/accent'), 'переменная color/accent есть');
  check(variableNames.includes('spacing/lg'), 'переменная spacing/lg есть');
  check(variableNames.includes('radius/pill'), 'переменная radius/pill есть');

  const accent = variables.find((variable) => variable.name === 'color/accent');
  check(
    accent && Math.abs(accent.values['mode:1'].r - 0x98 / 255) < 0.001,
    'color/accent = #9880FF',
  );
}

// --- Material kit ------------------------------------------------------------

const kitPage = pages.find((page) => page.name === data.kit.page);
const kitSpecs = data.kit.groups.flatMap((group) => group.items);
const kitComponents = kitPage
  ? kitPage.children.filter((node) => node.type === 'COMPONENT')
  : [];

check(kitPage, `страница «${data.kit.page}» создана`);
check(
  kitComponents.length === kitSpecs.length,
  `kit: ${kitSpecs.length} компонентов, получено ${kitComponents.length}`,
);

const spacingValues = new Set(data.spacing.map((step) => step.value));

for (const group of data.kit.groups) {
  for (const spec of group.items) {
    const component = kitComponents.find((node) => node.name === spec.name);
    check(component, `kit «${spec.name}» существует`);
    if (!component) continue;

    check(
      /^[A-Z][A-Za-z0-9]*( \/ [a-z]+)?$/.test(spec.name),
      `«${spec.name}»: имя начинается с класса Flutter`,
    );
    check(
      component.getPluginData('group') === group.name,
      `«${spec.name}»: группа «${group.name}»`,
    );
    check(component.getPluginData('dart').length > 0, `«${spec.name}»: сигнатура Dart есть`);
    check(component.description.length > 0, `«${spec.name}»: описание есть`);

    for (const [side, value] of Object.entries(spec.padding || {})) {
      check(
        value === 0 || spacingValues.has(value),
        `«${spec.name}»: padding ${side}=${value} не из токенов`,
      );
    }

    if (spec.layout && spec.layout.spacing) {
      check(
        spacingValues.has(spec.layout.spacing),
        `«${spec.name}»: spacing ${spec.layout.spacing} не из токенов`,
      );
    }
  }
}

const blocks = data.kit.groups.find((group) => group.name === 'Blocks');
for (const spec of blocks.items) {
  const component = kitComponents.find((node) => node.name === spec.name);
  check(
    component && component.children.some((child) => child.type === 'INSTANCE'),
    `блок «${spec.name}» собран из инстансов`,
  );
}

const scaffold = kitComponents.find((node) => node.name === 'Scaffold');
const appBar = kitComponents.find((node) => node.name === 'AppBar');
check(
  scaffold && appBar && scaffold.children[0].componentId === appBar.id,
  'Scaffold: AppBar — инстанс, ссылка на компонент цела',
);

// --- библиотека и вставка ----------------------------------------------------

// 1. После сборки плагин обязан обновить библиотеку сам, без запроса.
// Кеш на этом прогоне пуст, значит превью должны прийти потоком.
const library = await waitFor(['library']);

check(library.built === true, 'после сборки библиотека обновилась сама');
check(
  library.items.length === totalComponents,
  `библиотека: ${totalComponents} карточек, получено ${library.items.length}`,
);
check(
  library.items.every((item) => item.preview === null),
  'список отдаётся сразу, без ожидания экспорта',
);

const groups = new Set(library.items.map((item) => item.group));
for (const name of ['DND', ...data.kit.groups.map((group) => group.name)]) {
  check(groups.has(name), `библиотека: группа «${name}» есть`);
}

for (const item of library.items) {
  check(typeof item.id === 'string' && item.id.length > 0, `«${item.name}»: id есть`);
  check(typeof item.width === 'number' && item.width > 0, `«${item.name}»: ширина известна`);
  check(item.description.length > 0, `«${item.name}»: описание есть`);

  if (item.group === 'DND') {
    check(item.dart.startsWith('lib/'), `«${item.name}»: путь к Dart-файлу есть`);
  } else {
    check(item.dart.length > 0, `«${item.name}»: сигнатура Dart есть`);
  }
}

// Превью приходят потоком, уже после списка.
const previews = await waitForPreviews(totalComponents);
check(
  previews.length === totalComponents,
  `превью: ${totalComponents}, получено ${previews.length}`,
);
check(
  new Set(previews.map((message) => message.id)).size === totalComponents,
  'превью: по одному на компонент',
);
check(
  figma.clientStorage.store.has('dnd.previews.v1'),
  'превью закешированы в clientStorage',
);

// 2. Повторный запрос: кеш в памяти плагина отдаёт превью сразу.
messages.length = 0;
figma.ui.onmessage({ type: 'library' });
const cached = await waitFor(['library']);

check(
  cached.items.every((item) => typeof item.preview === 'string' && item.preview.length > 0),
  'кеш: повторный запрос отдаёт превью сразу',
);

await new Promise((resolve) => setTimeout(resolve, 5));
check(
  messages.filter((message) => message.type === 'preview').length === 0,
  'кеш: повторный экспорт не запускается',
);

// Вставка: после сборки текущая страница — kit, значит инстанс должен уехать на «Макеты».
const insertFrom = messages.length;
figma.ui.onmessage({ type: 'insert', nodeId: library.items[0].id });
const inserted = await waitFor(['inserted', 'error'], insertFrom);

if (inserted.type === 'error') fail('Вставка вернула ошибку: ' + inserted.message);

check(inserted.page === 'Макеты', `вставка увела на «Макеты», получено «${inserted.page}»`);
check(figma.currentPage === screensPage, 'текущая страница после вставки — «Макеты»');
check(
  screensPage.children.some(
    (node) => node.type === 'INSTANCE' && node.componentId === library.items[0].id,
  ),
  'инстанс лежит на странице «Макеты»',
);
check(
  !dsPage.children.some((node) => node.type === 'INSTANCE'),
  'на странице ДС инстансов нет',
);
check(
  !kitPage.children.some((node) => node.type === 'INSTANCE'),
  'на странице kit инстансов нет',
);
check(
  Array.isArray(figma.currentPage.selection) && figma.currentPage.selection.length === 1,
  'вставленный инстанс выделен',
);

// --- отчёт -------------------------------------------------------------------

console.log(`Сценарий: ${noVariables ? 'без Variables API' : 'полный'}`);
console.log(`Страница: ${dsPage.name}`);
console.log(`Компоненты (${components.length}):`);
for (const component of components) {
  const horizontal = component.layoutMode === 'HORIZONTAL';
  const width = horizontal && component.primaryAxisSizingMode === 'AUTO' ? 'hug' : String(component.width);
  const height = !horizontal && component.primaryAxisSizingMode === 'AUTO' ? 'hug' : String(component.height);
  console.log(`  ${component.name.padEnd(20)} ${width}×${height}  детей ${component.children.length}`);
}
console.log(
  `Переменные: ${variables.length}` + (collections[0] ? ` (${collections[0].name})` : ' (Variables API нет)'),
);
console.log(`Текстовые стили: ${textStyles.length}`);
console.log(`Kit (${kitComponents.length}): ${data.kit.groups.map((group) => `${group.name} ${group.items.length}`).join(', ')}`);
console.log(`Библиотека: ${library.items.length} карточек, групп ${groups.size}, превью ${previews.length}`);
console.log(`Вставка: «${library.items[0].name}» → «${inserted.page}», выделено ${figma.currentPage.selection.length}`);
console.log(`Шрифты: ${[...loadedFonts].join(', ')}`);
console.log(`Страницы: ${pages.map((page) => page.name).join(', ')}`);
if (warnings.length > 0) {
  console.log('Предупреждения плагина:');
  for (const warning of warnings) console.log('  ! ' + warning);
}

if (problems.length > 0) {
  console.error('\nПровалено:');
  for (const problem of problems) console.error('  - ' + problem);
  process.exit(1);
}

console.log('\nOK: контракт плагина соблюдён');

// --- утилиты -----------------------------------------------------------------

function check(condition, label) {
  if (!condition) problems.push(label);
}

/**
 * Ждёт сообщение нужного типа, начиная с индекса from. Плагин отвечает
 * асинхронно (экспорт превью — тоже async), поэтому ждём по тикам, а не
 * по первому сообщению в очереди.
 */
async function waitFor(types, from = 0) {
  for (let tick = 0; tick < 5000; tick += 1) {
    const found = messages.slice(from).find((message) => types.includes(message.type));
    if (found) return found;
    await new Promise((resolve) => setTimeout(resolve, 0));
  }
  fail(`Плагин не ответил (${types.join('/')}) за 5000 тиков`);
}

/** Превью досылаются по одному: ждём, пока наберётся count сообщений. */
async function waitForPreviews(count, from = 0) {
  let last = -1;
  let stable = 0;

  for (let tick = 0; tick < 5000; tick += 1) {
    const previews = messages.slice(from).filter((message) => message.type === 'preview');
    if (previews.length >= count) return previews;

    // Поток мог закончиться раньше: не ждём 5000 тиков впустую.
    if (previews.length === last) stable += 1;
    else {
      stable = 0;
      last = previews.length;
    }
    if (stable > 50) return previews;

    await new Promise((resolve) => setTimeout(resolve, 0));
  }

  return messages.slice(from).filter((message) => message.type === 'preview');
}

function fail(message) {
  console.error(message);
  process.exit(1);
}
