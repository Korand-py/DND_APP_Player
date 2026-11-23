// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CharacterRecordsTable extends CharacterRecords
    with TableInfo<$CharacterRecordsTable, CharacterRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharacterRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<String> classId = GeneratedColumn<String>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subclassIdMeta = const VerificationMeta(
    'subclassId',
  );
  @override
  late final GeneratedColumn<String> subclassId = GeneratedColumn<String>(
    'subclass_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _raceIdMeta = const VerificationMeta('raceId');
  @override
  late final GeneratedColumn<String> raceId = GeneratedColumn<String>(
    'race_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subraceIdMeta = const VerificationMeta(
    'subraceId',
  );
  @override
  late final GeneratedColumn<String> subraceId = GeneratedColumn<String>(
    'subrace_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _strengthMeta = const VerificationMeta(
    'strength',
  );
  @override
  late final GeneratedColumn<int> strength = GeneratedColumn<int>(
    'strength',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dexterityMeta = const VerificationMeta(
    'dexterity',
  );
  @override
  late final GeneratedColumn<int> dexterity = GeneratedColumn<int>(
    'dexterity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _constitutionMeta = const VerificationMeta(
    'constitution',
  );
  @override
  late final GeneratedColumn<int> constitution = GeneratedColumn<int>(
    'constitution',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intelligenceMeta = const VerificationMeta(
    'intelligence',
  );
  @override
  late final GeneratedColumn<int> intelligence = GeneratedColumn<int>(
    'intelligence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wisdomMeta = const VerificationMeta('wisdom');
  @override
  late final GeneratedColumn<int> wisdom = GeneratedColumn<int>(
    'wisdom',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _charismaMeta = const VerificationMeta(
    'charisma',
  );
  @override
  late final GeneratedColumn<int> charisma = GeneratedColumn<int>(
    'charisma',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    classId,
    subclassId,
    raceId,
    subraceId,
    level,
    strength,
    dexterity,
    constitution,
    intelligence,
    wisdom,
    charisma,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'character_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<CharacterRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('subclass_id')) {
      context.handle(
        _subclassIdMeta,
        subclassId.isAcceptableOrUnknown(data['subclass_id']!, _subclassIdMeta),
      );
    }
    if (data.containsKey('race_id')) {
      context.handle(
        _raceIdMeta,
        raceId.isAcceptableOrUnknown(data['race_id']!, _raceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_raceIdMeta);
    }
    if (data.containsKey('subrace_id')) {
      context.handle(
        _subraceIdMeta,
        subraceId.isAcceptableOrUnknown(data['subrace_id']!, _subraceIdMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('strength')) {
      context.handle(
        _strengthMeta,
        strength.isAcceptableOrUnknown(data['strength']!, _strengthMeta),
      );
    } else if (isInserting) {
      context.missing(_strengthMeta);
    }
    if (data.containsKey('dexterity')) {
      context.handle(
        _dexterityMeta,
        dexterity.isAcceptableOrUnknown(data['dexterity']!, _dexterityMeta),
      );
    } else if (isInserting) {
      context.missing(_dexterityMeta);
    }
    if (data.containsKey('constitution')) {
      context.handle(
        _constitutionMeta,
        constitution.isAcceptableOrUnknown(
          data['constitution']!,
          _constitutionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_constitutionMeta);
    }
    if (data.containsKey('intelligence')) {
      context.handle(
        _intelligenceMeta,
        intelligence.isAcceptableOrUnknown(
          data['intelligence']!,
          _intelligenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_intelligenceMeta);
    }
    if (data.containsKey('wisdom')) {
      context.handle(
        _wisdomMeta,
        wisdom.isAcceptableOrUnknown(data['wisdom']!, _wisdomMeta),
      );
    } else if (isInserting) {
      context.missing(_wisdomMeta);
    }
    if (data.containsKey('charisma')) {
      context.handle(
        _charismaMeta,
        charisma.isAcceptableOrUnknown(data['charisma']!, _charismaMeta),
      );
    } else if (isInserting) {
      context.missing(_charismaMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CharacterRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CharacterRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_id'],
      )!,
      subclassId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subclass_id'],
      ),
      raceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}race_id'],
      )!,
      subraceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subrace_id'],
      ),
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      strength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}strength'],
      )!,
      dexterity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dexterity'],
      )!,
      constitution: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}constitution'],
      )!,
      intelligence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intelligence'],
      )!,
      wisdom: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wisdom'],
      )!,
      charisma: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}charisma'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CharacterRecordsTable createAlias(String alias) {
    return $CharacterRecordsTable(attachedDatabase, alias);
  }
}

class CharacterRecord extends DataClass implements Insertable<CharacterRecord> {
  final int id;
  final String name;

  /// `DndClass.id`: `barbarian`, `wizard`…
  final String classId;

  /// `Subclass.id` или `null`, если подкласс не выбран.
  final String? subclassId;

  /// `Race.id`: `half-elf`, `dwarf`…
  final String raceId;

  /// `Subrace.id` или `null`, если у расы нет подрас.
  final String? subraceId;
  final int level;
  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;
  final DateTime createdAt;
  const CharacterRecord({
    required this.id,
    required this.name,
    required this.classId,
    this.subclassId,
    required this.raceId,
    this.subraceId,
    required this.level,
    required this.strength,
    required this.dexterity,
    required this.constitution,
    required this.intelligence,
    required this.wisdom,
    required this.charisma,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['class_id'] = Variable<String>(classId);
    if (!nullToAbsent || subclassId != null) {
      map['subclass_id'] = Variable<String>(subclassId);
    }
    map['race_id'] = Variable<String>(raceId);
    if (!nullToAbsent || subraceId != null) {
      map['subrace_id'] = Variable<String>(subraceId);
    }
    map['level'] = Variable<int>(level);
    map['strength'] = Variable<int>(strength);
    map['dexterity'] = Variable<int>(dexterity);
    map['constitution'] = Variable<int>(constitution);
    map['intelligence'] = Variable<int>(intelligence);
    map['wisdom'] = Variable<int>(wisdom);
    map['charisma'] = Variable<int>(charisma);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CharacterRecordsCompanion toCompanion(bool nullToAbsent) {
    return CharacterRecordsCompanion(
      id: Value(id),
      name: Value(name),
      classId: Value(classId),
      subclassId: subclassId == null && nullToAbsent
          ? const Value.absent()
          : Value(subclassId),
      raceId: Value(raceId),
      subraceId: subraceId == null && nullToAbsent
          ? const Value.absent()
          : Value(subraceId),
      level: Value(level),
      strength: Value(strength),
      dexterity: Value(dexterity),
      constitution: Value(constitution),
      intelligence: Value(intelligence),
      wisdom: Value(wisdom),
      charisma: Value(charisma),
      createdAt: Value(createdAt),
    );
  }

  factory CharacterRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CharacterRecord(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      classId: serializer.fromJson<String>(json['classId']),
      subclassId: serializer.fromJson<String?>(json['subclassId']),
      raceId: serializer.fromJson<String>(json['raceId']),
      subraceId: serializer.fromJson<String?>(json['subraceId']),
      level: serializer.fromJson<int>(json['level']),
      strength: serializer.fromJson<int>(json['strength']),
      dexterity: serializer.fromJson<int>(json['dexterity']),
      constitution: serializer.fromJson<int>(json['constitution']),
      intelligence: serializer.fromJson<int>(json['intelligence']),
      wisdom: serializer.fromJson<int>(json['wisdom']),
      charisma: serializer.fromJson<int>(json['charisma']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'classId': serializer.toJson<String>(classId),
      'subclassId': serializer.toJson<String?>(subclassId),
      'raceId': serializer.toJson<String>(raceId),
      'subraceId': serializer.toJson<String?>(subraceId),
      'level': serializer.toJson<int>(level),
      'strength': serializer.toJson<int>(strength),
      'dexterity': serializer.toJson<int>(dexterity),
      'constitution': serializer.toJson<int>(constitution),
      'intelligence': serializer.toJson<int>(intelligence),
      'wisdom': serializer.toJson<int>(wisdom),
      'charisma': serializer.toJson<int>(charisma),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CharacterRecord copyWith({
    int? id,
    String? name,
    String? classId,
    Value<String?> subclassId = const Value.absent(),
    String? raceId,
    Value<String?> subraceId = const Value.absent(),
    int? level,
    int? strength,
    int? dexterity,
    int? constitution,
    int? intelligence,
    int? wisdom,
    int? charisma,
    DateTime? createdAt,
  }) => CharacterRecord(
    id: id ?? this.id,
    name: name ?? this.name,
    classId: classId ?? this.classId,
    subclassId: subclassId.present ? subclassId.value : this.subclassId,
    raceId: raceId ?? this.raceId,
    subraceId: subraceId.present ? subraceId.value : this.subraceId,
    level: level ?? this.level,
    strength: strength ?? this.strength,
    dexterity: dexterity ?? this.dexterity,
    constitution: constitution ?? this.constitution,
    intelligence: intelligence ?? this.intelligence,
    wisdom: wisdom ?? this.wisdom,
    charisma: charisma ?? this.charisma,
    createdAt: createdAt ?? this.createdAt,
  );
  CharacterRecord copyWithCompanion(CharacterRecordsCompanion data) {
    return CharacterRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      classId: data.classId.present ? data.classId.value : this.classId,
      subclassId: data.subclassId.present
          ? data.subclassId.value
          : this.subclassId,
      raceId: data.raceId.present ? data.raceId.value : this.raceId,
      subraceId: data.subraceId.present ? data.subraceId.value : this.subraceId,
      level: data.level.present ? data.level.value : this.level,
      strength: data.strength.present ? data.strength.value : this.strength,
      dexterity: data.dexterity.present ? data.dexterity.value : this.dexterity,
      constitution: data.constitution.present
          ? data.constitution.value
          : this.constitution,
      intelligence: data.intelligence.present
          ? data.intelligence.value
          : this.intelligence,
      wisdom: data.wisdom.present ? data.wisdom.value : this.wisdom,
      charisma: data.charisma.present ? data.charisma.value : this.charisma,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CharacterRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('classId: $classId, ')
          ..write('subclassId: $subclassId, ')
          ..write('raceId: $raceId, ')
          ..write('subraceId: $subraceId, ')
          ..write('level: $level, ')
          ..write('strength: $strength, ')
          ..write('dexterity: $dexterity, ')
          ..write('constitution: $constitution, ')
          ..write('intelligence: $intelligence, ')
          ..write('wisdom: $wisdom, ')
          ..write('charisma: $charisma, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    classId,
    subclassId,
    raceId,
    subraceId,
    level,
    strength,
    dexterity,
    constitution,
    intelligence,
    wisdom,
    charisma,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharacterRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.classId == this.classId &&
          other.subclassId == this.subclassId &&
          other.raceId == this.raceId &&
          other.subraceId == this.subraceId &&
          other.level == this.level &&
          other.strength == this.strength &&
          other.dexterity == this.dexterity &&
          other.constitution == this.constitution &&
          other.intelligence == this.intelligence &&
          other.wisdom == this.wisdom &&
          other.charisma == this.charisma &&
          other.createdAt == this.createdAt);
}

class CharacterRecordsCompanion extends UpdateCompanion<CharacterRecord> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> classId;
  final Value<String?> subclassId;
  final Value<String> raceId;
  final Value<String?> subraceId;
  final Value<int> level;
  final Value<int> strength;
  final Value<int> dexterity;
  final Value<int> constitution;
  final Value<int> intelligence;
  final Value<int> wisdom;
  final Value<int> charisma;
  final Value<DateTime> createdAt;
  const CharacterRecordsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.classId = const Value.absent(),
    this.subclassId = const Value.absent(),
    this.raceId = const Value.absent(),
    this.subraceId = const Value.absent(),
    this.level = const Value.absent(),
    this.strength = const Value.absent(),
    this.dexterity = const Value.absent(),
    this.constitution = const Value.absent(),
    this.intelligence = const Value.absent(),
    this.wisdom = const Value.absent(),
    this.charisma = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CharacterRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String classId,
    this.subclassId = const Value.absent(),
    required String raceId,
    this.subraceId = const Value.absent(),
    this.level = const Value.absent(),
    required int strength,
    required int dexterity,
    required int constitution,
    required int intelligence,
    required int wisdom,
    required int charisma,
    required DateTime createdAt,
  }) : name = Value(name),
       classId = Value(classId),
       raceId = Value(raceId),
       strength = Value(strength),
       dexterity = Value(dexterity),
       constitution = Value(constitution),
       intelligence = Value(intelligence),
       wisdom = Value(wisdom),
       charisma = Value(charisma),
       createdAt = Value(createdAt);
  static Insertable<CharacterRecord> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? classId,
    Expression<String>? subclassId,
    Expression<String>? raceId,
    Expression<String>? subraceId,
    Expression<int>? level,
    Expression<int>? strength,
    Expression<int>? dexterity,
    Expression<int>? constitution,
    Expression<int>? intelligence,
    Expression<int>? wisdom,
    Expression<int>? charisma,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (classId != null) 'class_id': classId,
      if (subclassId != null) 'subclass_id': subclassId,
      if (raceId != null) 'race_id': raceId,
      if (subraceId != null) 'subrace_id': subraceId,
      if (level != null) 'level': level,
      if (strength != null) 'strength': strength,
      if (dexterity != null) 'dexterity': dexterity,
      if (constitution != null) 'constitution': constitution,
      if (intelligence != null) 'intelligence': intelligence,
      if (wisdom != null) 'wisdom': wisdom,
      if (charisma != null) 'charisma': charisma,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CharacterRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? classId,
    Value<String?>? subclassId,
    Value<String>? raceId,
    Value<String?>? subraceId,
    Value<int>? level,
    Value<int>? strength,
    Value<int>? dexterity,
    Value<int>? constitution,
    Value<int>? intelligence,
    Value<int>? wisdom,
    Value<int>? charisma,
    Value<DateTime>? createdAt,
  }) {
    return CharacterRecordsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      classId: classId ?? this.classId,
      subclassId: subclassId ?? this.subclassId,
      raceId: raceId ?? this.raceId,
      subraceId: subraceId ?? this.subraceId,
      level: level ?? this.level,
      strength: strength ?? this.strength,
      dexterity: dexterity ?? this.dexterity,
      constitution: constitution ?? this.constitution,
      intelligence: intelligence ?? this.intelligence,
      wisdom: wisdom ?? this.wisdom,
      charisma: charisma ?? this.charisma,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<String>(classId.value);
    }
    if (subclassId.present) {
      map['subclass_id'] = Variable<String>(subclassId.value);
    }
    if (raceId.present) {
      map['race_id'] = Variable<String>(raceId.value);
    }
    if (subraceId.present) {
      map['subrace_id'] = Variable<String>(subraceId.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (strength.present) {
      map['strength'] = Variable<int>(strength.value);
    }
    if (dexterity.present) {
      map['dexterity'] = Variable<int>(dexterity.value);
    }
    if (constitution.present) {
      map['constitution'] = Variable<int>(constitution.value);
    }
    if (intelligence.present) {
      map['intelligence'] = Variable<int>(intelligence.value);
    }
    if (wisdom.present) {
      map['wisdom'] = Variable<int>(wisdom.value);
    }
    if (charisma.present) {
      map['charisma'] = Variable<int>(charisma.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharacterRecordsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('classId: $classId, ')
          ..write('subclassId: $subclassId, ')
          ..write('raceId: $raceId, ')
          ..write('subraceId: $subraceId, ')
          ..write('level: $level, ')
          ..write('strength: $strength, ')
          ..write('dexterity: $dexterity, ')
          ..write('constitution: $constitution, ')
          ..write('intelligence: $intelligence, ')
          ..write('wisdom: $wisdom, ')
          ..write('charisma: $charisma, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CharacterRecordsTable characterRecords = $CharacterRecordsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [characterRecords];
}

typedef $$CharacterRecordsTableCreateCompanionBuilder =
    CharacterRecordsCompanion Function({
      Value<int> id,
      required String name,
      required String classId,
      Value<String?> subclassId,
      required String raceId,
      Value<String?> subraceId,
      Value<int> level,
      required int strength,
      required int dexterity,
      required int constitution,
      required int intelligence,
      required int wisdom,
      required int charisma,
      required DateTime createdAt,
    });
typedef $$CharacterRecordsTableUpdateCompanionBuilder =
    CharacterRecordsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> classId,
      Value<String?> subclassId,
      Value<String> raceId,
      Value<String?> subraceId,
      Value<int> level,
      Value<int> strength,
      Value<int> dexterity,
      Value<int> constitution,
      Value<int> intelligence,
      Value<int> wisdom,
      Value<int> charisma,
      Value<DateTime> createdAt,
    });

class $$CharacterRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $CharacterRecordsTable> {
  $$CharacterRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subclassId => $composableBuilder(
    column: $table.subclassId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get raceId => $composableBuilder(
    column: $table.raceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subraceId => $composableBuilder(
    column: $table.subraceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get strength => $composableBuilder(
    column: $table.strength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dexterity => $composableBuilder(
    column: $table.dexterity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get constitution => $composableBuilder(
    column: $table.constitution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intelligence => $composableBuilder(
    column: $table.intelligence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wisdom => $composableBuilder(
    column: $table.wisdom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get charisma => $composableBuilder(
    column: $table.charisma,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CharacterRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $CharacterRecordsTable> {
  $$CharacterRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subclassId => $composableBuilder(
    column: $table.subclassId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get raceId => $composableBuilder(
    column: $table.raceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subraceId => $composableBuilder(
    column: $table.subraceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get strength => $composableBuilder(
    column: $table.strength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dexterity => $composableBuilder(
    column: $table.dexterity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get constitution => $composableBuilder(
    column: $table.constitution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intelligence => $composableBuilder(
    column: $table.intelligence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wisdom => $composableBuilder(
    column: $table.wisdom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get charisma => $composableBuilder(
    column: $table.charisma,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CharacterRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharacterRecordsTable> {
  $$CharacterRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get classId =>
      $composableBuilder(column: $table.classId, builder: (column) => column);

  GeneratedColumn<String> get subclassId => $composableBuilder(
    column: $table.subclassId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get raceId =>
      $composableBuilder(column: $table.raceId, builder: (column) => column);

  GeneratedColumn<String> get subraceId =>
      $composableBuilder(column: $table.subraceId, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get strength =>
      $composableBuilder(column: $table.strength, builder: (column) => column);

  GeneratedColumn<int> get dexterity =>
      $composableBuilder(column: $table.dexterity, builder: (column) => column);

  GeneratedColumn<int> get constitution => $composableBuilder(
    column: $table.constitution,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intelligence => $composableBuilder(
    column: $table.intelligence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wisdom =>
      $composableBuilder(column: $table.wisdom, builder: (column) => column);

  GeneratedColumn<int> get charisma =>
      $composableBuilder(column: $table.charisma, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CharacterRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharacterRecordsTable,
          CharacterRecord,
          $$CharacterRecordsTableFilterComposer,
          $$CharacterRecordsTableOrderingComposer,
          $$CharacterRecordsTableAnnotationComposer,
          $$CharacterRecordsTableCreateCompanionBuilder,
          $$CharacterRecordsTableUpdateCompanionBuilder,
          (
            CharacterRecord,
            BaseReferences<
              _$AppDatabase,
              $CharacterRecordsTable,
              CharacterRecord
            >,
          ),
          CharacterRecord,
          PrefetchHooks Function()
        > {
  $$CharacterRecordsTableTableManager(
    _$AppDatabase db,
    $CharacterRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharacterRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CharacterRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CharacterRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> classId = const Value.absent(),
                Value<String?> subclassId = const Value.absent(),
                Value<String> raceId = const Value.absent(),
                Value<String?> subraceId = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> strength = const Value.absent(),
                Value<int> dexterity = const Value.absent(),
                Value<int> constitution = const Value.absent(),
                Value<int> intelligence = const Value.absent(),
                Value<int> wisdom = const Value.absent(),
                Value<int> charisma = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CharacterRecordsCompanion(
                id: id,
                name: name,
                classId: classId,
                subclassId: subclassId,
                raceId: raceId,
                subraceId: subraceId,
                level: level,
                strength: strength,
                dexterity: dexterity,
                constitution: constitution,
                intelligence: intelligence,
                wisdom: wisdom,
                charisma: charisma,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String classId,
                Value<String?> subclassId = const Value.absent(),
                required String raceId,
                Value<String?> subraceId = const Value.absent(),
                Value<int> level = const Value.absent(),
                required int strength,
                required int dexterity,
                required int constitution,
                required int intelligence,
                required int wisdom,
                required int charisma,
                required DateTime createdAt,
              }) => CharacterRecordsCompanion.insert(
                id: id,
                name: name,
                classId: classId,
                subclassId: subclassId,
                raceId: raceId,
                subraceId: subraceId,
                level: level,
                strength: strength,
                dexterity: dexterity,
                constitution: constitution,
                intelligence: intelligence,
                wisdom: wisdom,
                charisma: charisma,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CharacterRecordsTable, CharacterRecord>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CharacterRecordsTable,
                    CharacterRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CharacterRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharacterRecordsTable,
      CharacterRecord,
      $$CharacterRecordsTableFilterComposer,
      $$CharacterRecordsTableOrderingComposer,
      $$CharacterRecordsTableAnnotationComposer,
      $$CharacterRecordsTableCreateCompanionBuilder,
      $$CharacterRecordsTableUpdateCompanionBuilder,
      (
        CharacterRecord,
        BaseReferences<_$AppDatabase, $CharacterRecordsTable, CharacterRecord>,
      ),
      CharacterRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CharacterRecordsTableTableManager get characterRecords =>
      $$CharacterRecordsTableTableManager(_db, _db.characterRecords);
}
