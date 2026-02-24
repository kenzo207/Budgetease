// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<AccountType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<AccountType>($AccountsTable.$convertertype);
  static const VerificationMeta _currentBalanceMeta =
      const VerificationMeta('currentBalance');
  @override
  late final GeneratedColumn<double> currentBalance = GeneratedColumn<double>(
      'current_balance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operatorMeta =
      const VerificationMeta('operator');
  @override
  late final GeneratedColumn<String> operator = GeneratedColumn<String>(
      'operator', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        type,
        currentBalance,
        icon,
        color,
        operator,
        isActive,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(Insertable<Account> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('current_balance')) {
      context.handle(
          _currentBalanceMeta,
          currentBalance.isAcceptableOrUnknown(
              data['current_balance']!, _currentBalanceMeta));
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('operator')) {
      context.handle(_operatorMeta,
          operator.isAcceptableOrUnknown(data['operator']!, _operatorMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: $AccountsTable.$convertertype.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      currentBalance: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}current_balance'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      operator: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operator']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AccountType, int, int> $convertertype =
      const EnumIndexConverter<AccountType>(AccountType.values);
}

class Account extends DataClass implements Insertable<Account> {
  final int id;
  final String name;
  final AccountType type;
  final double currentBalance;
  final String icon;
  final String color;
  final String? operator;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Account(
      {required this.id,
      required this.name,
      required this.type,
      required this.currentBalance,
      required this.icon,
      required this.color,
      this.operator,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<int>($AccountsTable.$convertertype.toSql(type));
    }
    map['current_balance'] = Variable<double>(currentBalance);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<String>(color);
    if (!nullToAbsent || operator != null) {
      map['operator'] = Variable<String>(operator);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      currentBalance: Value(currentBalance),
      icon: Value(icon),
      color: Value(color),
      operator: operator == null && nullToAbsent
          ? const Value.absent()
          : Value(operator),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Account.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: $AccountsTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
      currentBalance: serializer.fromJson<double>(json['currentBalance']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<String>(json['color']),
      operator: serializer.fromJson<String?>(json['operator']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type':
          serializer.toJson<int>($AccountsTable.$convertertype.toJson(type)),
      'currentBalance': serializer.toJson<double>(currentBalance),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<String>(color),
      'operator': serializer.toJson<String?>(operator),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Account copyWith(
          {int? id,
          String? name,
          AccountType? type,
          double? currentBalance,
          String? icon,
          String? color,
          Value<String?> operator = const Value.absent(),
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Account(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        currentBalance: currentBalance ?? this.currentBalance,
        icon: icon ?? this.icon,
        color: color ?? this.color,
        operator: operator.present ? operator.value : this.operator,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      currentBalance: data.currentBalance.present
          ? data.currentBalance.value
          : this.currentBalance,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      operator: data.operator.present ? data.operator.value : this.operator,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('operator: $operator, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type, currentBalance, icon, color,
      operator, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.currentBalance == this.currentBalance &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.operator == this.operator &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<int> id;
  final Value<String> name;
  final Value<AccountType> type;
  final Value<double> currentBalance;
  final Value<String> icon;
  final Value<String> color;
  final Value<String?> operator;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.currentBalance = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.operator = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required AccountType type,
    this.currentBalance = const Value.absent(),
    required String icon,
    required String color,
    this.operator = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : name = Value(name),
        type = Value(type),
        icon = Value(icon),
        color = Value(color),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Account> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? type,
    Expression<double>? currentBalance,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<String>? operator,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (currentBalance != null) 'current_balance': currentBalance,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (operator != null) 'operator': operator,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AccountsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<AccountType>? type,
      Value<double>? currentBalance,
      Value<String>? icon,
      Value<String>? color,
      Value<String?>? operator,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      currentBalance: currentBalance ?? this.currentBalance,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      operator: operator ?? this.operator,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (type.present) {
      map['type'] =
          Variable<int>($AccountsTable.$convertertype.toSql(type.value));
    }
    if (currentBalance.present) {
      map['current_balance'] = Variable<double>(currentBalance.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (operator.present) {
      map['operator'] = Variable<String>(operator.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('operator: $operator, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<CategoryType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<CategoryType>($CategoriesTable.$convertertype);
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, icon, color, type, isDefault, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      type: $CategoriesTable.$convertertype.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CategoryType, int, int> $convertertype =
      const EnumIndexConverter<CategoryType>(CategoryType.values);
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final String icon;
  final String color;
  final CategoryType type;
  final bool isDefault;
  final DateTime createdAt;
  const Category(
      {required this.id,
      required this.name,
      required this.icon,
      required this.color,
      required this.type,
      required this.isDefault,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<String>(color);
    {
      map['type'] = Variable<int>($CategoriesTable.$convertertype.toSql(type));
    }
    map['is_default'] = Variable<bool>(isDefault);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      color: Value(color),
      type: Value(type),
      isDefault: Value(isDefault),
      createdAt: Value(createdAt),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<String>(json['color']),
      type: $CategoriesTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<String>(color),
      'type':
          serializer.toJson<int>($CategoriesTable.$convertertype.toJson(type)),
      'isDefault': serializer.toJson<bool>(isDefault),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Category copyWith(
          {int? id,
          String? name,
          String? icon,
          String? color,
          CategoryType? type,
          bool? isDefault,
          DateTime? createdAt}) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        color: color ?? this.color,
        type: type ?? this.type,
        isDefault: isDefault ?? this.isDefault,
        createdAt: createdAt ?? this.createdAt,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      type: data.type.present ? data.type.value : this.type,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('type: $type, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, icon, color, type, isDefault, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.type == this.type &&
          other.isDefault == this.isDefault &&
          other.createdAt == this.createdAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<String> color;
  final Value<CategoryType> type;
  final Value<bool> isDefault;
  final Value<DateTime> createdAt;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.type = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String icon,
    required String color,
    required CategoryType type,
    this.isDefault = const Value.absent(),
    required DateTime createdAt,
  })  : name = Value(name),
        icon = Value(icon),
        color = Value(color),
        type = Value(type),
        createdAt = Value(createdAt);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<int>? type,
    Expression<bool>? isDefault,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (type != null) 'type': type,
      if (isDefault != null) 'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CategoriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? icon,
      Value<String>? color,
      Value<CategoryType>? type,
      Value<bool>? isDefault,
      Value<DateTime>? createdAt}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
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
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (type.present) {
      map['type'] =
          Variable<int>($CategoriesTable.$convertertype.toSql(type.value));
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('type: $type, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<TransactionType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<TransactionType>($TransactionsTable.$convertertype);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES accounts (id)'));
  static const VerificationMeta _toAccountIdMeta =
      const VerificationMeta('toAccountId');
  @override
  late final GeneratedColumn<int> toAccountId = GeneratedColumn<int>(
      'to_account_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES accounts (id)'));
  static const VerificationMeta _feeAmountMeta =
      const VerificationMeta('feeAmount');
  @override
  late final GeneratedColumn<double> feeAmount = GeneratedColumn<double>(
      'fee_amount', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _isExceptionMeta =
      const VerificationMeta('isException');
  @override
  late final GeneratedColumn<bool> isException = GeneratedColumn<bool>(
      'is_exception', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_exception" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _scopeDurationMeta =
      const VerificationMeta('scopeDuration');
  @override
  late final GeneratedColumn<int> scopeDuration = GeneratedColumn<int>(
      'scope_duration', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _scopeTypeMeta =
      const VerificationMeta('scopeType');
  @override
  late final GeneratedColumn<String> scopeType = GeneratedColumn<String>(
      'scope_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        amount,
        type,
        date,
        categoryId,
        accountId,
        toAccountId,
        feeAmount,
        isException,
        scopeDuration,
        scopeType,
        description,
        source,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('to_account_id')) {
      context.handle(
          _toAccountIdMeta,
          toAccountId.isAcceptableOrUnknown(
              data['to_account_id']!, _toAccountIdMeta));
    }
    if (data.containsKey('fee_amount')) {
      context.handle(_feeAmountMeta,
          feeAmount.isAcceptableOrUnknown(data['fee_amount']!, _feeAmountMeta));
    }
    if (data.containsKey('is_exception')) {
      context.handle(
          _isExceptionMeta,
          isException.isAcceptableOrUnknown(
              data['is_exception']!, _isExceptionMeta));
    }
    if (data.containsKey('scope_duration')) {
      context.handle(
          _scopeDurationMeta,
          scopeDuration.isAcceptableOrUnknown(
              data['scope_duration']!, _scopeDurationMeta));
    }
    if (data.containsKey('scope_type')) {
      context.handle(_scopeTypeMeta,
          scopeType.isAcceptableOrUnknown(data['scope_type']!, _scopeTypeMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      type: $TransactionsTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id']),
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id'])!,
      toAccountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}to_account_id']),
      feeAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fee_amount']),
      isException: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_exception'])!,
      scopeDuration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}scope_duration']),
      scopeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scope_type']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TransactionType, int, int> $convertertype =
      const EnumIndexConverter<TransactionType>(TransactionType.values);
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final int? categoryId;
  final int accountId;
  final int? toAccountId;
  final double? feeAmount;
  final bool isException;
  final int? scopeDuration;
  final String? scopeType;
  final String? description;
  final String? source;
  final DateTime createdAt;
  const Transaction(
      {required this.id,
      required this.amount,
      required this.type,
      required this.date,
      this.categoryId,
      required this.accountId,
      this.toAccountId,
      this.feeAmount,
      required this.isException,
      this.scopeDuration,
      this.scopeType,
      this.description,
      this.source,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount'] = Variable<double>(amount);
    {
      map['type'] =
          Variable<int>($TransactionsTable.$convertertype.toSql(type));
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['account_id'] = Variable<int>(accountId);
    if (!nullToAbsent || toAccountId != null) {
      map['to_account_id'] = Variable<int>(toAccountId);
    }
    if (!nullToAbsent || feeAmount != null) {
      map['fee_amount'] = Variable<double>(feeAmount);
    }
    map['is_exception'] = Variable<bool>(isException);
    if (!nullToAbsent || scopeDuration != null) {
      map['scope_duration'] = Variable<int>(scopeDuration);
    }
    if (!nullToAbsent || scopeType != null) {
      map['scope_type'] = Variable<String>(scopeType);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      amount: Value(amount),
      type: Value(type),
      date: Value(date),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      accountId: Value(accountId),
      toAccountId: toAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(toAccountId),
      feeAmount: feeAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(feeAmount),
      isException: Value(isException),
      scopeDuration: scopeDuration == null && nullToAbsent
          ? const Value.absent()
          : Value(scopeDuration),
      scopeType: scopeType == null && nullToAbsent
          ? const Value.absent()
          : Value(scopeType),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      source:
          source == null && nullToAbsent ? const Value.absent() : Value(source),
      createdAt: Value(createdAt),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      type: $TransactionsTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
      date: serializer.fromJson<DateTime>(json['date']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      accountId: serializer.fromJson<int>(json['accountId']),
      toAccountId: serializer.fromJson<int?>(json['toAccountId']),
      feeAmount: serializer.fromJson<double?>(json['feeAmount']),
      isException: serializer.fromJson<bool>(json['isException']),
      scopeDuration: serializer.fromJson<int?>(json['scopeDuration']),
      scopeType: serializer.fromJson<String?>(json['scopeType']),
      description: serializer.fromJson<String?>(json['description']),
      source: serializer.fromJson<String?>(json['source']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amount': serializer.toJson<double>(amount),
      'type': serializer
          .toJson<int>($TransactionsTable.$convertertype.toJson(type)),
      'date': serializer.toJson<DateTime>(date),
      'categoryId': serializer.toJson<int?>(categoryId),
      'accountId': serializer.toJson<int>(accountId),
      'toAccountId': serializer.toJson<int?>(toAccountId),
      'feeAmount': serializer.toJson<double?>(feeAmount),
      'isException': serializer.toJson<bool>(isException),
      'scopeDuration': serializer.toJson<int?>(scopeDuration),
      'scopeType': serializer.toJson<String?>(scopeType),
      'description': serializer.toJson<String?>(description),
      'source': serializer.toJson<String?>(source),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Transaction copyWith(
          {int? id,
          double? amount,
          TransactionType? type,
          DateTime? date,
          Value<int?> categoryId = const Value.absent(),
          int? accountId,
          Value<int?> toAccountId = const Value.absent(),
          Value<double?> feeAmount = const Value.absent(),
          bool? isException,
          Value<int?> scopeDuration = const Value.absent(),
          Value<String?> scopeType = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<String?> source = const Value.absent(),
          DateTime? createdAt}) =>
      Transaction(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        date: date ?? this.date,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        accountId: accountId ?? this.accountId,
        toAccountId: toAccountId.present ? toAccountId.value : this.toAccountId,
        feeAmount: feeAmount.present ? feeAmount.value : this.feeAmount,
        isException: isException ?? this.isException,
        scopeDuration:
            scopeDuration.present ? scopeDuration.value : this.scopeDuration,
        scopeType: scopeType.present ? scopeType.value : this.scopeType,
        description: description.present ? description.value : this.description,
        source: source.present ? source.value : this.source,
        createdAt: createdAt ?? this.createdAt,
      );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      type: data.type.present ? data.type.value : this.type,
      date: data.date.present ? data.date.value : this.date,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      toAccountId:
          data.toAccountId.present ? data.toAccountId.value : this.toAccountId,
      feeAmount: data.feeAmount.present ? data.feeAmount.value : this.feeAmount,
      isException:
          data.isException.present ? data.isException.value : this.isException,
      scopeDuration: data.scopeDuration.present
          ? data.scopeDuration.value
          : this.scopeDuration,
      scopeType: data.scopeType.present ? data.scopeType.value : this.scopeType,
      description:
          data.description.present ? data.description.value : this.description,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('date: $date, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('feeAmount: $feeAmount, ')
          ..write('isException: $isException, ')
          ..write('scopeDuration: $scopeDuration, ')
          ..write('scopeType: $scopeType, ')
          ..write('description: $description, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      amount,
      type,
      date,
      categoryId,
      accountId,
      toAccountId,
      feeAmount,
      isException,
      scopeDuration,
      scopeType,
      description,
      source,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.type == this.type &&
          other.date == this.date &&
          other.categoryId == this.categoryId &&
          other.accountId == this.accountId &&
          other.toAccountId == this.toAccountId &&
          other.feeAmount == this.feeAmount &&
          other.isException == this.isException &&
          other.scopeDuration == this.scopeDuration &&
          other.scopeType == this.scopeType &&
          other.description == this.description &&
          other.source == this.source &&
          other.createdAt == this.createdAt);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<double> amount;
  final Value<TransactionType> type;
  final Value<DateTime> date;
  final Value<int?> categoryId;
  final Value<int> accountId;
  final Value<int?> toAccountId;
  final Value<double?> feeAmount;
  final Value<bool> isException;
  final Value<int?> scopeDuration;
  final Value<String?> scopeType;
  final Value<String?> description;
  final Value<String?> source;
  final Value<DateTime> createdAt;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.type = const Value.absent(),
    this.date = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.feeAmount = const Value.absent(),
    this.isException = const Value.absent(),
    this.scopeDuration = const Value.absent(),
    this.scopeType = const Value.absent(),
    this.description = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required double amount,
    required TransactionType type,
    required DateTime date,
    this.categoryId = const Value.absent(),
    required int accountId,
    this.toAccountId = const Value.absent(),
    this.feeAmount = const Value.absent(),
    this.isException = const Value.absent(),
    this.scopeDuration = const Value.absent(),
    this.scopeType = const Value.absent(),
    this.description = const Value.absent(),
    this.source = const Value.absent(),
    required DateTime createdAt,
  })  : amount = Value(amount),
        type = Value(type),
        date = Value(date),
        accountId = Value(accountId),
        createdAt = Value(createdAt);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<double>? amount,
    Expression<int>? type,
    Expression<DateTime>? date,
    Expression<int>? categoryId,
    Expression<int>? accountId,
    Expression<int>? toAccountId,
    Expression<double>? feeAmount,
    Expression<bool>? isException,
    Expression<int>? scopeDuration,
    Expression<String>? scopeType,
    Expression<String>? description,
    Expression<String>? source,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (type != null) 'type': type,
      if (date != null) 'date': date,
      if (categoryId != null) 'category_id': categoryId,
      if (accountId != null) 'account_id': accountId,
      if (toAccountId != null) 'to_account_id': toAccountId,
      if (feeAmount != null) 'fee_amount': feeAmount,
      if (isException != null) 'is_exception': isException,
      if (scopeDuration != null) 'scope_duration': scopeDuration,
      if (scopeType != null) 'scope_type': scopeType,
      if (description != null) 'description': description,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TransactionsCompanion copyWith(
      {Value<int>? id,
      Value<double>? amount,
      Value<TransactionType>? type,
      Value<DateTime>? date,
      Value<int?>? categoryId,
      Value<int>? accountId,
      Value<int?>? toAccountId,
      Value<double?>? feeAmount,
      Value<bool>? isException,
      Value<int?>? scopeDuration,
      Value<String?>? scopeType,
      Value<String?>? description,
      Value<String?>? source,
      Value<DateTime>? createdAt}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      feeAmount: feeAmount ?? this.feeAmount,
      isException: isException ?? this.isException,
      scopeDuration: scopeDuration ?? this.scopeDuration,
      scopeType: scopeType ?? this.scopeType,
      description: description ?? this.description,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (type.present) {
      map['type'] =
          Variable<int>($TransactionsTable.$convertertype.toSql(type.value));
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (toAccountId.present) {
      map['to_account_id'] = Variable<int>(toAccountId.value);
    }
    if (feeAmount.present) {
      map['fee_amount'] = Variable<double>(feeAmount.value);
    }
    if (isException.present) {
      map['is_exception'] = Variable<bool>(isException.value);
    }
    if (scopeDuration.present) {
      map['scope_duration'] = Variable<int>(scopeDuration.value);
    }
    if (scopeType.present) {
      map['scope_type'] = Variable<String>(scopeType.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('date: $date, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('feeAmount: $feeAmount, ')
          ..write('isException: $isException, ')
          ..write('scopeDuration: $scopeDuration, ')
          ..write('scopeType: $scopeType, ')
          ..write('description: $description, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RecurringChargesTable extends RecurringCharges
    with TableInfo<$RecurringChargesTable, RecurringCharge> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringChargesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<ChargeType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<ChargeType>($RecurringChargesTable.$convertertype);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<ChargeCycle, int> cycle =
      GeneratedColumn<int>('cycle', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<ChargeCycle>($RecurringChargesTable.$convertercycle);
  static const VerificationMeta _isPaidMeta = const VerificationMeta('isPaid');
  @override
  late final GeneratedColumn<bool> isPaid = GeneratedColumn<bool>(
      'is_paid', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_paid" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, type, amount, dueDate, cycle, isPaid, isActive, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_charges';
  @override
  VerificationContext validateIntegrity(Insertable<RecurringCharge> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('is_paid')) {
      context.handle(_isPaidMeta,
          isPaid.isAcceptableOrUnknown(data['is_paid']!, _isPaidMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringCharge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringCharge(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: $RecurringChargesTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date'])!,
      cycle: $RecurringChargesTable.$convertercycle.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cycle'])!),
      isPaid: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_paid'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $RecurringChargesTable createAlias(String alias) {
    return $RecurringChargesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ChargeType, int, int> $convertertype =
      const EnumIndexConverter<ChargeType>(ChargeType.values);
  static JsonTypeConverter2<ChargeCycle, int, int> $convertercycle =
      const EnumIndexConverter<ChargeCycle>(ChargeCycle.values);
}

class RecurringCharge extends DataClass implements Insertable<RecurringCharge> {
  final int id;
  final String name;
  final ChargeType type;
  final double amount;
  final DateTime dueDate;
  final ChargeCycle cycle;
  final bool isPaid;
  final bool isActive;
  final DateTime createdAt;
  const RecurringCharge(
      {required this.id,
      required this.name,
      required this.type,
      required this.amount,
      required this.dueDate,
      required this.cycle,
      required this.isPaid,
      required this.isActive,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['type'] =
          Variable<int>($RecurringChargesTable.$convertertype.toSql(type));
    }
    map['amount'] = Variable<double>(amount);
    map['due_date'] = Variable<DateTime>(dueDate);
    {
      map['cycle'] =
          Variable<int>($RecurringChargesTable.$convertercycle.toSql(cycle));
    }
    map['is_paid'] = Variable<bool>(isPaid);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RecurringChargesCompanion toCompanion(bool nullToAbsent) {
    return RecurringChargesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      amount: Value(amount),
      dueDate: Value(dueDate),
      cycle: Value(cycle),
      isPaid: Value(isPaid),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory RecurringCharge.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringCharge(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: $RecurringChargesTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
      amount: serializer.fromJson<double>(json['amount']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      cycle: $RecurringChargesTable.$convertercycle
          .fromJson(serializer.fromJson<int>(json['cycle'])),
      isPaid: serializer.fromJson<bool>(json['isPaid']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer
          .toJson<int>($RecurringChargesTable.$convertertype.toJson(type)),
      'amount': serializer.toJson<double>(amount),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'cycle': serializer
          .toJson<int>($RecurringChargesTable.$convertercycle.toJson(cycle)),
      'isPaid': serializer.toJson<bool>(isPaid),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RecurringCharge copyWith(
          {int? id,
          String? name,
          ChargeType? type,
          double? amount,
          DateTime? dueDate,
          ChargeCycle? cycle,
          bool? isPaid,
          bool? isActive,
          DateTime? createdAt}) =>
      RecurringCharge(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        dueDate: dueDate ?? this.dueDate,
        cycle: cycle ?? this.cycle,
        isPaid: isPaid ?? this.isPaid,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
  RecurringCharge copyWithCompanion(RecurringChargesCompanion data) {
    return RecurringCharge(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      cycle: data.cycle.present ? data.cycle.value : this.cycle,
      isPaid: data.isPaid.present ? data.isPaid.value : this.isPaid,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringCharge(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('dueDate: $dueDate, ')
          ..write('cycle: $cycle, ')
          ..write('isPaid: $isPaid, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, type, amount, dueDate, cycle, isPaid, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringCharge &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.dueDate == this.dueDate &&
          other.cycle == this.cycle &&
          other.isPaid == this.isPaid &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class RecurringChargesCompanion extends UpdateCompanion<RecurringCharge> {
  final Value<int> id;
  final Value<String> name;
  final Value<ChargeType> type;
  final Value<double> amount;
  final Value<DateTime> dueDate;
  final Value<ChargeCycle> cycle;
  final Value<bool> isPaid;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const RecurringChargesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.cycle = const Value.absent(),
    this.isPaid = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RecurringChargesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required ChargeType type,
    required double amount,
    required DateTime dueDate,
    required ChargeCycle cycle,
    this.isPaid = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
  })  : name = Value(name),
        type = Value(type),
        amount = Value(amount),
        dueDate = Value(dueDate),
        cycle = Value(cycle),
        createdAt = Value(createdAt);
  static Insertable<RecurringCharge> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? type,
    Expression<double>? amount,
    Expression<DateTime>? dueDate,
    Expression<int>? cycle,
    Expression<bool>? isPaid,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (dueDate != null) 'due_date': dueDate,
      if (cycle != null) 'cycle': cycle,
      if (isPaid != null) 'is_paid': isPaid,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RecurringChargesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<ChargeType>? type,
      Value<double>? amount,
      Value<DateTime>? dueDate,
      Value<ChargeCycle>? cycle,
      Value<bool>? isPaid,
      Value<bool>? isActive,
      Value<DateTime>? createdAt}) {
    return RecurringChargesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      cycle: cycle ?? this.cycle,
      isPaid: isPaid ?? this.isPaid,
      isActive: isActive ?? this.isActive,
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
    if (type.present) {
      map['type'] = Variable<int>(
          $RecurringChargesTable.$convertertype.toSql(type.value));
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (cycle.present) {
      map['cycle'] = Variable<int>(
          $RecurringChargesTable.$convertercycle.toSql(cycle.value));
    }
    if (isPaid.present) {
      map['is_paid'] = Variable<bool>(isPaid.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringChargesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('dueDate: $dueDate, ')
          ..write('cycle: $cycle, ')
          ..write('isPaid: $isPaid, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PendingTransactionsTable extends PendingTransactions
    with TableInfo<$PendingTransactionsTable, PendingTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _operatorMeta =
      const VerificationMeta('operator');
  @override
  late final GeneratedColumn<String> operator = GeneratedColumn<String>(
      'operator', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<MomoTransactionType, int>
      momoType = GeneratedColumn<int>('momo_type', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: Constant(MomoTransactionType.unknown.index))
          .withConverter<MomoTransactionType>(
              $PendingTransactionsTable.$convertermomoType);
  static const VerificationMeta _feeMeta = const VerificationMeta('fee');
  @override
  late final GeneratedColumn<double> fee = GeneratedColumn<double>(
      'fee', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _balanceAfterMeta =
      const VerificationMeta('balanceAfter');
  @override
  late final GeneratedColumn<double> balanceAfter = GeneratedColumn<double>(
      'balance_after', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _counterpartMeta =
      const VerificationMeta('counterpart');
  @override
  late final GeneratedColumn<String> counterpart = GeneratedColumn<String>(
      'counterpart', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _counterpartPhoneMeta =
      const VerificationMeta('counterpartPhone');
  @override
  late final GeneratedColumn<String> counterpartPhone = GeneratedColumn<String>(
      'counterpart_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _momoRefMeta =
      const VerificationMeta('momoRef');
  @override
  late final GeneratedColumn<String> momoRef = GeneratedColumn<String>(
      'momo_ref', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _transactionDateMeta =
      const VerificationMeta('transactionDate');
  @override
  late final GeneratedColumn<DateTime> transactionDate =
      GeneratedColumn<DateTime>('transaction_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _rawSmsMeta = const VerificationMeta('rawSms');
  @override
  late final GeneratedColumn<String> rawSms = GeneratedColumn<String>(
      'raw_sms', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _smsDateMeta =
      const VerificationMeta('smsDate');
  @override
  late final GeneratedColumn<DateTime> smsDate = GeneratedColumn<DateTime>(
      'sms_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
      'transaction_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isProcessedMeta =
      const VerificationMeta('isProcessed');
  @override
  late final GeneratedColumn<bool> isProcessed = GeneratedColumn<bool>(
      'is_processed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_processed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _countsInBudgetMeta =
      const VerificationMeta('countsInBudget');
  @override
  late final GeneratedColumn<bool> countsInBudget = GeneratedColumn<bool>(
      'counts_in_budget', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("counts_in_budget" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _suggestedAccountIdMeta =
      const VerificationMeta('suggestedAccountId');
  @override
  late final GeneratedColumn<int> suggestedAccountId = GeneratedColumn<int>(
      'suggested_account_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES accounts (id)'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        amount,
        operator,
        momoType,
        fee,
        balanceAfter,
        counterpart,
        counterpartPhone,
        momoRef,
        transactionDate,
        rawSms,
        smsDate,
        transactionId,
        isProcessed,
        countsInBudget,
        suggestedAccountId,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_transactions';
  @override
  VerificationContext validateIntegrity(Insertable<PendingTransaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('operator')) {
      context.handle(_operatorMeta,
          operator.isAcceptableOrUnknown(data['operator']!, _operatorMeta));
    } else if (isInserting) {
      context.missing(_operatorMeta);
    }
    if (data.containsKey('fee')) {
      context.handle(
          _feeMeta, fee.isAcceptableOrUnknown(data['fee']!, _feeMeta));
    }
    if (data.containsKey('balance_after')) {
      context.handle(
          _balanceAfterMeta,
          balanceAfter.isAcceptableOrUnknown(
              data['balance_after']!, _balanceAfterMeta));
    }
    if (data.containsKey('counterpart')) {
      context.handle(
          _counterpartMeta,
          counterpart.isAcceptableOrUnknown(
              data['counterpart']!, _counterpartMeta));
    }
    if (data.containsKey('counterpart_phone')) {
      context.handle(
          _counterpartPhoneMeta,
          counterpartPhone.isAcceptableOrUnknown(
              data['counterpart_phone']!, _counterpartPhoneMeta));
    }
    if (data.containsKey('momo_ref')) {
      context.handle(_momoRefMeta,
          momoRef.isAcceptableOrUnknown(data['momo_ref']!, _momoRefMeta));
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
          _transactionDateMeta,
          transactionDate.isAcceptableOrUnknown(
              data['transaction_date']!, _transactionDateMeta));
    }
    if (data.containsKey('raw_sms')) {
      context.handle(_rawSmsMeta,
          rawSms.isAcceptableOrUnknown(data['raw_sms']!, _rawSmsMeta));
    } else if (isInserting) {
      context.missing(_rawSmsMeta);
    }
    if (data.containsKey('sms_date')) {
      context.handle(_smsDateMeta,
          smsDate.isAcceptableOrUnknown(data['sms_date']!, _smsDateMeta));
    } else if (isInserting) {
      context.missing(_smsDateMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    }
    if (data.containsKey('is_processed')) {
      context.handle(
          _isProcessedMeta,
          isProcessed.isAcceptableOrUnknown(
              data['is_processed']!, _isProcessedMeta));
    }
    if (data.containsKey('counts_in_budget')) {
      context.handle(
          _countsInBudgetMeta,
          countsInBudget.isAcceptableOrUnknown(
              data['counts_in_budget']!, _countsInBudgetMeta));
    }
    if (data.containsKey('suggested_account_id')) {
      context.handle(
          _suggestedAccountIdMeta,
          suggestedAccountId.isAcceptableOrUnknown(
              data['suggested_account_id']!, _suggestedAccountIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingTransaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      operator: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operator'])!,
      momoType: $PendingTransactionsTable.$convertermomoType.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}momo_type'])!),
      fee: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fee'])!,
      balanceAfter: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}balance_after']),
      counterpart: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}counterpart']),
      counterpartPhone: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}counterpart_phone']),
      momoRef: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}momo_ref']),
      transactionDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}transaction_date']),
      rawSms: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_sms'])!,
      smsDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}sms_date'])!,
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transaction_id']),
      isProcessed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_processed'])!,
      countsInBudget: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}counts_in_budget'])!,
      suggestedAccountId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}suggested_account_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PendingTransactionsTable createAlias(String alias) {
    return $PendingTransactionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MomoTransactionType, int, int> $convertermomoType =
      const EnumIndexConverter<MomoTransactionType>(MomoTransactionType.values);
}

class PendingTransaction extends DataClass
    implements Insertable<PendingTransaction> {
  final int id;
  final double amount;
  final String operator;
  final MomoTransactionType momoType;
  final double fee;
  final double? balanceAfter;
  final String? counterpart;
  final String? counterpartPhone;
  final String? momoRef;
  final DateTime? transactionDate;
  final String rawSms;
  final DateTime smsDate;
  final String? transactionId;
  final bool isProcessed;
  final bool countsInBudget;
  final int? suggestedAccountId;
  final DateTime createdAt;
  const PendingTransaction(
      {required this.id,
      required this.amount,
      required this.operator,
      required this.momoType,
      required this.fee,
      this.balanceAfter,
      this.counterpart,
      this.counterpartPhone,
      this.momoRef,
      this.transactionDate,
      required this.rawSms,
      required this.smsDate,
      this.transactionId,
      required this.isProcessed,
      required this.countsInBudget,
      this.suggestedAccountId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount'] = Variable<double>(amount);
    map['operator'] = Variable<String>(operator);
    {
      map['momo_type'] = Variable<int>(
          $PendingTransactionsTable.$convertermomoType.toSql(momoType));
    }
    map['fee'] = Variable<double>(fee);
    if (!nullToAbsent || balanceAfter != null) {
      map['balance_after'] = Variable<double>(balanceAfter);
    }
    if (!nullToAbsent || counterpart != null) {
      map['counterpart'] = Variable<String>(counterpart);
    }
    if (!nullToAbsent || counterpartPhone != null) {
      map['counterpart_phone'] = Variable<String>(counterpartPhone);
    }
    if (!nullToAbsent || momoRef != null) {
      map['momo_ref'] = Variable<String>(momoRef);
    }
    if (!nullToAbsent || transactionDate != null) {
      map['transaction_date'] = Variable<DateTime>(transactionDate);
    }
    map['raw_sms'] = Variable<String>(rawSms);
    map['sms_date'] = Variable<DateTime>(smsDate);
    if (!nullToAbsent || transactionId != null) {
      map['transaction_id'] = Variable<String>(transactionId);
    }
    map['is_processed'] = Variable<bool>(isProcessed);
    map['counts_in_budget'] = Variable<bool>(countsInBudget);
    if (!nullToAbsent || suggestedAccountId != null) {
      map['suggested_account_id'] = Variable<int>(suggestedAccountId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PendingTransactionsCompanion toCompanion(bool nullToAbsent) {
    return PendingTransactionsCompanion(
      id: Value(id),
      amount: Value(amount),
      operator: Value(operator),
      momoType: Value(momoType),
      fee: Value(fee),
      balanceAfter: balanceAfter == null && nullToAbsent
          ? const Value.absent()
          : Value(balanceAfter),
      counterpart: counterpart == null && nullToAbsent
          ? const Value.absent()
          : Value(counterpart),
      counterpartPhone: counterpartPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(counterpartPhone),
      momoRef: momoRef == null && nullToAbsent
          ? const Value.absent()
          : Value(momoRef),
      transactionDate: transactionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionDate),
      rawSms: Value(rawSms),
      smsDate: Value(smsDate),
      transactionId: transactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionId),
      isProcessed: Value(isProcessed),
      countsInBudget: Value(countsInBudget),
      suggestedAccountId: suggestedAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestedAccountId),
      createdAt: Value(createdAt),
    );
  }

  factory PendingTransaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingTransaction(
      id: serializer.fromJson<int>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      operator: serializer.fromJson<String>(json['operator']),
      momoType: $PendingTransactionsTable.$convertermomoType
          .fromJson(serializer.fromJson<int>(json['momoType'])),
      fee: serializer.fromJson<double>(json['fee']),
      balanceAfter: serializer.fromJson<double?>(json['balanceAfter']),
      counterpart: serializer.fromJson<String?>(json['counterpart']),
      counterpartPhone: serializer.fromJson<String?>(json['counterpartPhone']),
      momoRef: serializer.fromJson<String?>(json['momoRef']),
      transactionDate: serializer.fromJson<DateTime?>(json['transactionDate']),
      rawSms: serializer.fromJson<String>(json['rawSms']),
      smsDate: serializer.fromJson<DateTime>(json['smsDate']),
      transactionId: serializer.fromJson<String?>(json['transactionId']),
      isProcessed: serializer.fromJson<bool>(json['isProcessed']),
      countsInBudget: serializer.fromJson<bool>(json['countsInBudget']),
      suggestedAccountId: serializer.fromJson<int?>(json['suggestedAccountId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amount': serializer.toJson<double>(amount),
      'operator': serializer.toJson<String>(operator),
      'momoType': serializer.toJson<int>(
          $PendingTransactionsTable.$convertermomoType.toJson(momoType)),
      'fee': serializer.toJson<double>(fee),
      'balanceAfter': serializer.toJson<double?>(balanceAfter),
      'counterpart': serializer.toJson<String?>(counterpart),
      'counterpartPhone': serializer.toJson<String?>(counterpartPhone),
      'momoRef': serializer.toJson<String?>(momoRef),
      'transactionDate': serializer.toJson<DateTime?>(transactionDate),
      'rawSms': serializer.toJson<String>(rawSms),
      'smsDate': serializer.toJson<DateTime>(smsDate),
      'transactionId': serializer.toJson<String?>(transactionId),
      'isProcessed': serializer.toJson<bool>(isProcessed),
      'countsInBudget': serializer.toJson<bool>(countsInBudget),
      'suggestedAccountId': serializer.toJson<int?>(suggestedAccountId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PendingTransaction copyWith(
          {int? id,
          double? amount,
          String? operator,
          MomoTransactionType? momoType,
          double? fee,
          Value<double?> balanceAfter = const Value.absent(),
          Value<String?> counterpart = const Value.absent(),
          Value<String?> counterpartPhone = const Value.absent(),
          Value<String?> momoRef = const Value.absent(),
          Value<DateTime?> transactionDate = const Value.absent(),
          String? rawSms,
          DateTime? smsDate,
          Value<String?> transactionId = const Value.absent(),
          bool? isProcessed,
          bool? countsInBudget,
          Value<int?> suggestedAccountId = const Value.absent(),
          DateTime? createdAt}) =>
      PendingTransaction(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        operator: operator ?? this.operator,
        momoType: momoType ?? this.momoType,
        fee: fee ?? this.fee,
        balanceAfter:
            balanceAfter.present ? balanceAfter.value : this.balanceAfter,
        counterpart: counterpart.present ? counterpart.value : this.counterpart,
        counterpartPhone: counterpartPhone.present
            ? counterpartPhone.value
            : this.counterpartPhone,
        momoRef: momoRef.present ? momoRef.value : this.momoRef,
        transactionDate: transactionDate.present
            ? transactionDate.value
            : this.transactionDate,
        rawSms: rawSms ?? this.rawSms,
        smsDate: smsDate ?? this.smsDate,
        transactionId:
            transactionId.present ? transactionId.value : this.transactionId,
        isProcessed: isProcessed ?? this.isProcessed,
        countsInBudget: countsInBudget ?? this.countsInBudget,
        suggestedAccountId: suggestedAccountId.present
            ? suggestedAccountId.value
            : this.suggestedAccountId,
        createdAt: createdAt ?? this.createdAt,
      );
  PendingTransaction copyWithCompanion(PendingTransactionsCompanion data) {
    return PendingTransaction(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      operator: data.operator.present ? data.operator.value : this.operator,
      momoType: data.momoType.present ? data.momoType.value : this.momoType,
      fee: data.fee.present ? data.fee.value : this.fee,
      balanceAfter: data.balanceAfter.present
          ? data.balanceAfter.value
          : this.balanceAfter,
      counterpart:
          data.counterpart.present ? data.counterpart.value : this.counterpart,
      counterpartPhone: data.counterpartPhone.present
          ? data.counterpartPhone.value
          : this.counterpartPhone,
      momoRef: data.momoRef.present ? data.momoRef.value : this.momoRef,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      rawSms: data.rawSms.present ? data.rawSms.value : this.rawSms,
      smsDate: data.smsDate.present ? data.smsDate.value : this.smsDate,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      isProcessed:
          data.isProcessed.present ? data.isProcessed.value : this.isProcessed,
      countsInBudget: data.countsInBudget.present
          ? data.countsInBudget.value
          : this.countsInBudget,
      suggestedAccountId: data.suggestedAccountId.present
          ? data.suggestedAccountId.value
          : this.suggestedAccountId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingTransaction(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('operator: $operator, ')
          ..write('momoType: $momoType, ')
          ..write('fee: $fee, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('counterpart: $counterpart, ')
          ..write('counterpartPhone: $counterpartPhone, ')
          ..write('momoRef: $momoRef, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('rawSms: $rawSms, ')
          ..write('smsDate: $smsDate, ')
          ..write('transactionId: $transactionId, ')
          ..write('isProcessed: $isProcessed, ')
          ..write('countsInBudget: $countsInBudget, ')
          ..write('suggestedAccountId: $suggestedAccountId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      amount,
      operator,
      momoType,
      fee,
      balanceAfter,
      counterpart,
      counterpartPhone,
      momoRef,
      transactionDate,
      rawSms,
      smsDate,
      transactionId,
      isProcessed,
      countsInBudget,
      suggestedAccountId,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingTransaction &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.operator == this.operator &&
          other.momoType == this.momoType &&
          other.fee == this.fee &&
          other.balanceAfter == this.balanceAfter &&
          other.counterpart == this.counterpart &&
          other.counterpartPhone == this.counterpartPhone &&
          other.momoRef == this.momoRef &&
          other.transactionDate == this.transactionDate &&
          other.rawSms == this.rawSms &&
          other.smsDate == this.smsDate &&
          other.transactionId == this.transactionId &&
          other.isProcessed == this.isProcessed &&
          other.countsInBudget == this.countsInBudget &&
          other.suggestedAccountId == this.suggestedAccountId &&
          other.createdAt == this.createdAt);
}

class PendingTransactionsCompanion extends UpdateCompanion<PendingTransaction> {
  final Value<int> id;
  final Value<double> amount;
  final Value<String> operator;
  final Value<MomoTransactionType> momoType;
  final Value<double> fee;
  final Value<double?> balanceAfter;
  final Value<String?> counterpart;
  final Value<String?> counterpartPhone;
  final Value<String?> momoRef;
  final Value<DateTime?> transactionDate;
  final Value<String> rawSms;
  final Value<DateTime> smsDate;
  final Value<String?> transactionId;
  final Value<bool> isProcessed;
  final Value<bool> countsInBudget;
  final Value<int?> suggestedAccountId;
  final Value<DateTime> createdAt;
  const PendingTransactionsCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.operator = const Value.absent(),
    this.momoType = const Value.absent(),
    this.fee = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    this.counterpart = const Value.absent(),
    this.counterpartPhone = const Value.absent(),
    this.momoRef = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.rawSms = const Value.absent(),
    this.smsDate = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.isProcessed = const Value.absent(),
    this.countsInBudget = const Value.absent(),
    this.suggestedAccountId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PendingTransactionsCompanion.insert({
    this.id = const Value.absent(),
    required double amount,
    required String operator,
    this.momoType = const Value.absent(),
    this.fee = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    this.counterpart = const Value.absent(),
    this.counterpartPhone = const Value.absent(),
    this.momoRef = const Value.absent(),
    this.transactionDate = const Value.absent(),
    required String rawSms,
    required DateTime smsDate,
    this.transactionId = const Value.absent(),
    this.isProcessed = const Value.absent(),
    this.countsInBudget = const Value.absent(),
    this.suggestedAccountId = const Value.absent(),
    required DateTime createdAt,
  })  : amount = Value(amount),
        operator = Value(operator),
        rawSms = Value(rawSms),
        smsDate = Value(smsDate),
        createdAt = Value(createdAt);
  static Insertable<PendingTransaction> custom({
    Expression<int>? id,
    Expression<double>? amount,
    Expression<String>? operator,
    Expression<int>? momoType,
    Expression<double>? fee,
    Expression<double>? balanceAfter,
    Expression<String>? counterpart,
    Expression<String>? counterpartPhone,
    Expression<String>? momoRef,
    Expression<DateTime>? transactionDate,
    Expression<String>? rawSms,
    Expression<DateTime>? smsDate,
    Expression<String>? transactionId,
    Expression<bool>? isProcessed,
    Expression<bool>? countsInBudget,
    Expression<int>? suggestedAccountId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (operator != null) 'operator': operator,
      if (momoType != null) 'momo_type': momoType,
      if (fee != null) 'fee': fee,
      if (balanceAfter != null) 'balance_after': balanceAfter,
      if (counterpart != null) 'counterpart': counterpart,
      if (counterpartPhone != null) 'counterpart_phone': counterpartPhone,
      if (momoRef != null) 'momo_ref': momoRef,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (rawSms != null) 'raw_sms': rawSms,
      if (smsDate != null) 'sms_date': smsDate,
      if (transactionId != null) 'transaction_id': transactionId,
      if (isProcessed != null) 'is_processed': isProcessed,
      if (countsInBudget != null) 'counts_in_budget': countsInBudget,
      if (suggestedAccountId != null)
        'suggested_account_id': suggestedAccountId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PendingTransactionsCompanion copyWith(
      {Value<int>? id,
      Value<double>? amount,
      Value<String>? operator,
      Value<MomoTransactionType>? momoType,
      Value<double>? fee,
      Value<double?>? balanceAfter,
      Value<String?>? counterpart,
      Value<String?>? counterpartPhone,
      Value<String?>? momoRef,
      Value<DateTime?>? transactionDate,
      Value<String>? rawSms,
      Value<DateTime>? smsDate,
      Value<String?>? transactionId,
      Value<bool>? isProcessed,
      Value<bool>? countsInBudget,
      Value<int?>? suggestedAccountId,
      Value<DateTime>? createdAt}) {
    return PendingTransactionsCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      operator: operator ?? this.operator,
      momoType: momoType ?? this.momoType,
      fee: fee ?? this.fee,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      counterpart: counterpart ?? this.counterpart,
      counterpartPhone: counterpartPhone ?? this.counterpartPhone,
      momoRef: momoRef ?? this.momoRef,
      transactionDate: transactionDate ?? this.transactionDate,
      rawSms: rawSms ?? this.rawSms,
      smsDate: smsDate ?? this.smsDate,
      transactionId: transactionId ?? this.transactionId,
      isProcessed: isProcessed ?? this.isProcessed,
      countsInBudget: countsInBudget ?? this.countsInBudget,
      suggestedAccountId: suggestedAccountId ?? this.suggestedAccountId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (operator.present) {
      map['operator'] = Variable<String>(operator.value);
    }
    if (momoType.present) {
      map['momo_type'] = Variable<int>(
          $PendingTransactionsTable.$convertermomoType.toSql(momoType.value));
    }
    if (fee.present) {
      map['fee'] = Variable<double>(fee.value);
    }
    if (balanceAfter.present) {
      map['balance_after'] = Variable<double>(balanceAfter.value);
    }
    if (counterpart.present) {
      map['counterpart'] = Variable<String>(counterpart.value);
    }
    if (counterpartPhone.present) {
      map['counterpart_phone'] = Variable<String>(counterpartPhone.value);
    }
    if (momoRef.present) {
      map['momo_ref'] = Variable<String>(momoRef.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<DateTime>(transactionDate.value);
    }
    if (rawSms.present) {
      map['raw_sms'] = Variable<String>(rawSms.value);
    }
    if (smsDate.present) {
      map['sms_date'] = Variable<DateTime>(smsDate.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (isProcessed.present) {
      map['is_processed'] = Variable<bool>(isProcessed.value);
    }
    if (countsInBudget.present) {
      map['counts_in_budget'] = Variable<bool>(countsInBudget.value);
    }
    if (suggestedAccountId.present) {
      map['suggested_account_id'] = Variable<int>(suggestedAccountId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('operator: $operator, ')
          ..write('momoType: $momoType, ')
          ..write('fee: $fee, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('counterpart: $counterpart, ')
          ..write('counterpartPhone: $counterpartPhone, ')
          ..write('momoRef: $momoRef, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('rawSms: $rawSms, ')
          ..write('smsDate: $smsDate, ')
          ..write('transactionId: $transactionId, ')
          ..write('isProcessed: $isProcessed, ')
          ..write('countsInBudget: $countsInBudget, ')
          ..write('suggestedAccountId: $suggestedAccountId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, UserSettings> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userNameMeta =
      const VerificationMeta('userName');
  @override
  late final GeneratedColumn<String> userName = GeneratedColumn<String>(
      'user_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('FCFA'));
  @override
  late final GeneratedColumnWithTypeConverter<FinancialCycle, int>
      financialCycle = GeneratedColumn<int>(
              'financial_cycle', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<FinancialCycle>(
              $SettingsTable.$converterfinancialCycle);
  @override
  late final GeneratedColumnWithTypeConverter<TransportMode, int>
      transportMode = GeneratedColumn<int>('transport_mode', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<TransportMode>($SettingsTable.$convertertransportMode);
  static const VerificationMeta _dailyTransportCostMeta =
      const VerificationMeta('dailyTransportCost');
  @override
  late final GeneratedColumn<double> dailyTransportCost =
      GeneratedColumn<double>('daily_transport_cost', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _transportDaysPerWeekMeta =
      const VerificationMeta('transportDaysPerWeek');
  @override
  late final GeneratedColumn<int> transportDaysPerWeek = GeneratedColumn<int>(
      'transport_days_per_week', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _fixedTransportAmountMeta =
      const VerificationMeta('fixedTransportAmount');
  @override
  late final GeneratedColumn<double> fixedTransportAmount =
      GeneratedColumn<double>('fixed_transport_amount', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _biometricEnabledMeta =
      const VerificationMeta('biometricEnabled');
  @override
  late final GeneratedColumn<bool> biometricEnabled = GeneratedColumn<bool>(
      'biometric_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("biometric_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _pinEnabledMeta =
      const VerificationMeta('pinEnabled');
  @override
  late final GeneratedColumn<bool> pinEnabled = GeneratedColumn<bool>(
      'pin_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("pin_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _discreteModeEnabledMeta =
      const VerificationMeta('discreteModeEnabled');
  @override
  late final GeneratedColumn<bool> discreteModeEnabled = GeneratedColumn<bool>(
      'discrete_mode_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("discrete_mode_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _smsParsingEnabledMeta =
      const VerificationMeta('smsParsingEnabled');
  @override
  late final GeneratedColumn<bool> smsParsingEnabled = GeneratedColumn<bool>(
      'sms_parsing_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("sms_parsing_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _savingsGoalMeta =
      const VerificationMeta('savingsGoal');
  @override
  late final GeneratedColumn<double> savingsGoal = GeneratedColumn<double>(
      'savings_goal', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _onboardingCompletedMeta =
      const VerificationMeta('onboardingCompleted');
  @override
  late final GeneratedColumn<bool> onboardingCompleted = GeneratedColumn<bool>(
      'onboarding_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("onboarding_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _borderColorMeta =
      const VerificationMeta('borderColor');
  @override
  late final GeneratedColumn<String> borderColor = GeneratedColumn<String>(
      'border_color', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#4CAF50'));
  @override
  late final GeneratedColumnWithTypeConverter<ThemeModePreference, int>
      themeMode = GeneratedColumn<int>('theme_mode', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: const Constant(0))
          .withConverter<ThemeModePreference>(
              $SettingsTable.$converterthemeMode);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userName,
        currency,
        financialCycle,
        transportMode,
        dailyTransportCost,
        transportDaysPerWeek,
        fixedTransportAmount,
        biometricEnabled,
        pinEnabled,
        discreteModeEnabled,
        smsParsingEnabled,
        savingsGoal,
        onboardingCompleted,
        borderColor,
        themeMode,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<UserSettings> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_name')) {
      context.handle(_userNameMeta,
          userName.isAcceptableOrUnknown(data['user_name']!, _userNameMeta));
    } else if (isInserting) {
      context.missing(_userNameMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('daily_transport_cost')) {
      context.handle(
          _dailyTransportCostMeta,
          dailyTransportCost.isAcceptableOrUnknown(
              data['daily_transport_cost']!, _dailyTransportCostMeta));
    }
    if (data.containsKey('transport_days_per_week')) {
      context.handle(
          _transportDaysPerWeekMeta,
          transportDaysPerWeek.isAcceptableOrUnknown(
              data['transport_days_per_week']!, _transportDaysPerWeekMeta));
    }
    if (data.containsKey('fixed_transport_amount')) {
      context.handle(
          _fixedTransportAmountMeta,
          fixedTransportAmount.isAcceptableOrUnknown(
              data['fixed_transport_amount']!, _fixedTransportAmountMeta));
    }
    if (data.containsKey('biometric_enabled')) {
      context.handle(
          _biometricEnabledMeta,
          biometricEnabled.isAcceptableOrUnknown(
              data['biometric_enabled']!, _biometricEnabledMeta));
    }
    if (data.containsKey('pin_enabled')) {
      context.handle(
          _pinEnabledMeta,
          pinEnabled.isAcceptableOrUnknown(
              data['pin_enabled']!, _pinEnabledMeta));
    }
    if (data.containsKey('discrete_mode_enabled')) {
      context.handle(
          _discreteModeEnabledMeta,
          discreteModeEnabled.isAcceptableOrUnknown(
              data['discrete_mode_enabled']!, _discreteModeEnabledMeta));
    }
    if (data.containsKey('sms_parsing_enabled')) {
      context.handle(
          _smsParsingEnabledMeta,
          smsParsingEnabled.isAcceptableOrUnknown(
              data['sms_parsing_enabled']!, _smsParsingEnabledMeta));
    }
    if (data.containsKey('savings_goal')) {
      context.handle(
          _savingsGoalMeta,
          savingsGoal.isAcceptableOrUnknown(
              data['savings_goal']!, _savingsGoalMeta));
    }
    if (data.containsKey('onboarding_completed')) {
      context.handle(
          _onboardingCompletedMeta,
          onboardingCompleted.isAcceptableOrUnknown(
              data['onboarding_completed']!, _onboardingCompletedMeta));
    }
    if (data.containsKey('border_color')) {
      context.handle(
          _borderColorMeta,
          borderColor.isAcceptableOrUnknown(
              data['border_color']!, _borderColorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserSettings map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSettings(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_name'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      financialCycle: $SettingsTable.$converterfinancialCycle.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.int, data['${effectivePrefix}financial_cycle'])!),
      transportMode: $SettingsTable.$convertertransportMode.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.int, data['${effectivePrefix}transport_mode'])!),
      dailyTransportCost: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}daily_transport_cost']),
      transportDaysPerWeek: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}transport_days_per_week']),
      fixedTransportAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}fixed_transport_amount']),
      biometricEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}biometric_enabled'])!,
      pinEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pin_enabled'])!,
      discreteModeEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}discrete_mode_enabled'])!,
      smsParsingEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}sms_parsing_enabled'])!,
      savingsGoal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}savings_goal'])!,
      onboardingCompleted: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}onboarding_completed'])!,
      borderColor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}border_color']),
      themeMode: $SettingsTable.$converterthemeMode.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}theme_mode'])!),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FinancialCycle, int, int> $converterfinancialCycle =
      const EnumIndexConverter<FinancialCycle>(FinancialCycle.values);
  static JsonTypeConverter2<TransportMode, int, int> $convertertransportMode =
      const EnumIndexConverter<TransportMode>(TransportMode.values);
  static JsonTypeConverter2<ThemeModePreference, int, int> $converterthemeMode =
      const EnumIndexConverter<ThemeModePreference>(ThemeModePreference.values);
}

class UserSettings extends DataClass implements Insertable<UserSettings> {
  final int id;
  final String userName;
  final String currency;
  final FinancialCycle financialCycle;
  final TransportMode transportMode;
  final double? dailyTransportCost;
  final int? transportDaysPerWeek;
  final double? fixedTransportAmount;
  final bool biometricEnabled;
  final bool pinEnabled;
  final bool discreteModeEnabled;
  final bool smsParsingEnabled;
  final double savingsGoal;
  final bool onboardingCompleted;
  final String? borderColor;
  final ThemeModePreference themeMode;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserSettings(
      {required this.id,
      required this.userName,
      required this.currency,
      required this.financialCycle,
      required this.transportMode,
      this.dailyTransportCost,
      this.transportDaysPerWeek,
      this.fixedTransportAmount,
      required this.biometricEnabled,
      required this.pinEnabled,
      required this.discreteModeEnabled,
      required this.smsParsingEnabled,
      required this.savingsGoal,
      required this.onboardingCompleted,
      this.borderColor,
      required this.themeMode,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_name'] = Variable<String>(userName);
    map['currency'] = Variable<String>(currency);
    {
      map['financial_cycle'] = Variable<int>(
          $SettingsTable.$converterfinancialCycle.toSql(financialCycle));
    }
    {
      map['transport_mode'] = Variable<int>(
          $SettingsTable.$convertertransportMode.toSql(transportMode));
    }
    if (!nullToAbsent || dailyTransportCost != null) {
      map['daily_transport_cost'] = Variable<double>(dailyTransportCost);
    }
    if (!nullToAbsent || transportDaysPerWeek != null) {
      map['transport_days_per_week'] = Variable<int>(transportDaysPerWeek);
    }
    if (!nullToAbsent || fixedTransportAmount != null) {
      map['fixed_transport_amount'] = Variable<double>(fixedTransportAmount);
    }
    map['biometric_enabled'] = Variable<bool>(biometricEnabled);
    map['pin_enabled'] = Variable<bool>(pinEnabled);
    map['discrete_mode_enabled'] = Variable<bool>(discreteModeEnabled);
    map['sms_parsing_enabled'] = Variable<bool>(smsParsingEnabled);
    map['savings_goal'] = Variable<double>(savingsGoal);
    map['onboarding_completed'] = Variable<bool>(onboardingCompleted);
    if (!nullToAbsent || borderColor != null) {
      map['border_color'] = Variable<String>(borderColor);
    }
    {
      map['theme_mode'] =
          Variable<int>($SettingsTable.$converterthemeMode.toSql(themeMode));
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      userName: Value(userName),
      currency: Value(currency),
      financialCycle: Value(financialCycle),
      transportMode: Value(transportMode),
      dailyTransportCost: dailyTransportCost == null && nullToAbsent
          ? const Value.absent()
          : Value(dailyTransportCost),
      transportDaysPerWeek: transportDaysPerWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(transportDaysPerWeek),
      fixedTransportAmount: fixedTransportAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(fixedTransportAmount),
      biometricEnabled: Value(biometricEnabled),
      pinEnabled: Value(pinEnabled),
      discreteModeEnabled: Value(discreteModeEnabled),
      smsParsingEnabled: Value(smsParsingEnabled),
      savingsGoal: Value(savingsGoal),
      onboardingCompleted: Value(onboardingCompleted),
      borderColor: borderColor == null && nullToAbsent
          ? const Value.absent()
          : Value(borderColor),
      themeMode: Value(themeMode),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserSettings.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSettings(
      id: serializer.fromJson<int>(json['id']),
      userName: serializer.fromJson<String>(json['userName']),
      currency: serializer.fromJson<String>(json['currency']),
      financialCycle: $SettingsTable.$converterfinancialCycle
          .fromJson(serializer.fromJson<int>(json['financialCycle'])),
      transportMode: $SettingsTable.$convertertransportMode
          .fromJson(serializer.fromJson<int>(json['transportMode'])),
      dailyTransportCost:
          serializer.fromJson<double?>(json['dailyTransportCost']),
      transportDaysPerWeek:
          serializer.fromJson<int?>(json['transportDaysPerWeek']),
      fixedTransportAmount:
          serializer.fromJson<double?>(json['fixedTransportAmount']),
      biometricEnabled: serializer.fromJson<bool>(json['biometricEnabled']),
      pinEnabled: serializer.fromJson<bool>(json['pinEnabled']),
      discreteModeEnabled:
          serializer.fromJson<bool>(json['discreteModeEnabled']),
      smsParsingEnabled: serializer.fromJson<bool>(json['smsParsingEnabled']),
      savingsGoal: serializer.fromJson<double>(json['savingsGoal']),
      onboardingCompleted:
          serializer.fromJson<bool>(json['onboardingCompleted']),
      borderColor: serializer.fromJson<String?>(json['borderColor']),
      themeMode: $SettingsTable.$converterthemeMode
          .fromJson(serializer.fromJson<int>(json['themeMode'])),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userName': serializer.toJson<String>(userName),
      'currency': serializer.toJson<String>(currency),
      'financialCycle': serializer.toJson<int>(
          $SettingsTable.$converterfinancialCycle.toJson(financialCycle)),
      'transportMode': serializer.toJson<int>(
          $SettingsTable.$convertertransportMode.toJson(transportMode)),
      'dailyTransportCost': serializer.toJson<double?>(dailyTransportCost),
      'transportDaysPerWeek': serializer.toJson<int?>(transportDaysPerWeek),
      'fixedTransportAmount': serializer.toJson<double?>(fixedTransportAmount),
      'biometricEnabled': serializer.toJson<bool>(biometricEnabled),
      'pinEnabled': serializer.toJson<bool>(pinEnabled),
      'discreteModeEnabled': serializer.toJson<bool>(discreteModeEnabled),
      'smsParsingEnabled': serializer.toJson<bool>(smsParsingEnabled),
      'savingsGoal': serializer.toJson<double>(savingsGoal),
      'onboardingCompleted': serializer.toJson<bool>(onboardingCompleted),
      'borderColor': serializer.toJson<String?>(borderColor),
      'themeMode': serializer
          .toJson<int>($SettingsTable.$converterthemeMode.toJson(themeMode)),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserSettings copyWith(
          {int? id,
          String? userName,
          String? currency,
          FinancialCycle? financialCycle,
          TransportMode? transportMode,
          Value<double?> dailyTransportCost = const Value.absent(),
          Value<int?> transportDaysPerWeek = const Value.absent(),
          Value<double?> fixedTransportAmount = const Value.absent(),
          bool? biometricEnabled,
          bool? pinEnabled,
          bool? discreteModeEnabled,
          bool? smsParsingEnabled,
          double? savingsGoal,
          bool? onboardingCompleted,
          Value<String?> borderColor = const Value.absent(),
          ThemeModePreference? themeMode,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      UserSettings(
        id: id ?? this.id,
        userName: userName ?? this.userName,
        currency: currency ?? this.currency,
        financialCycle: financialCycle ?? this.financialCycle,
        transportMode: transportMode ?? this.transportMode,
        dailyTransportCost: dailyTransportCost.present
            ? dailyTransportCost.value
            : this.dailyTransportCost,
        transportDaysPerWeek: transportDaysPerWeek.present
            ? transportDaysPerWeek.value
            : this.transportDaysPerWeek,
        fixedTransportAmount: fixedTransportAmount.present
            ? fixedTransportAmount.value
            : this.fixedTransportAmount,
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
        pinEnabled: pinEnabled ?? this.pinEnabled,
        discreteModeEnabled: discreteModeEnabled ?? this.discreteModeEnabled,
        smsParsingEnabled: smsParsingEnabled ?? this.smsParsingEnabled,
        savingsGoal: savingsGoal ?? this.savingsGoal,
        onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
        borderColor: borderColor.present ? borderColor.value : this.borderColor,
        themeMode: themeMode ?? this.themeMode,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserSettings copyWithCompanion(SettingsCompanion data) {
    return UserSettings(
      id: data.id.present ? data.id.value : this.id,
      userName: data.userName.present ? data.userName.value : this.userName,
      currency: data.currency.present ? data.currency.value : this.currency,
      financialCycle: data.financialCycle.present
          ? data.financialCycle.value
          : this.financialCycle,
      transportMode: data.transportMode.present
          ? data.transportMode.value
          : this.transportMode,
      dailyTransportCost: data.dailyTransportCost.present
          ? data.dailyTransportCost.value
          : this.dailyTransportCost,
      transportDaysPerWeek: data.transportDaysPerWeek.present
          ? data.transportDaysPerWeek.value
          : this.transportDaysPerWeek,
      fixedTransportAmount: data.fixedTransportAmount.present
          ? data.fixedTransportAmount.value
          : this.fixedTransportAmount,
      biometricEnabled: data.biometricEnabled.present
          ? data.biometricEnabled.value
          : this.biometricEnabled,
      pinEnabled:
          data.pinEnabled.present ? data.pinEnabled.value : this.pinEnabled,
      discreteModeEnabled: data.discreteModeEnabled.present
          ? data.discreteModeEnabled.value
          : this.discreteModeEnabled,
      smsParsingEnabled: data.smsParsingEnabled.present
          ? data.smsParsingEnabled.value
          : this.smsParsingEnabled,
      savingsGoal:
          data.savingsGoal.present ? data.savingsGoal.value : this.savingsGoal,
      onboardingCompleted: data.onboardingCompleted.present
          ? data.onboardingCompleted.value
          : this.onboardingCompleted,
      borderColor:
          data.borderColor.present ? data.borderColor.value : this.borderColor,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSettings(')
          ..write('id: $id, ')
          ..write('userName: $userName, ')
          ..write('currency: $currency, ')
          ..write('financialCycle: $financialCycle, ')
          ..write('transportMode: $transportMode, ')
          ..write('dailyTransportCost: $dailyTransportCost, ')
          ..write('transportDaysPerWeek: $transportDaysPerWeek, ')
          ..write('fixedTransportAmount: $fixedTransportAmount, ')
          ..write('biometricEnabled: $biometricEnabled, ')
          ..write('pinEnabled: $pinEnabled, ')
          ..write('discreteModeEnabled: $discreteModeEnabled, ')
          ..write('smsParsingEnabled: $smsParsingEnabled, ')
          ..write('savingsGoal: $savingsGoal, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('borderColor: $borderColor, ')
          ..write('themeMode: $themeMode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userName,
      currency,
      financialCycle,
      transportMode,
      dailyTransportCost,
      transportDaysPerWeek,
      fixedTransportAmount,
      biometricEnabled,
      pinEnabled,
      discreteModeEnabled,
      smsParsingEnabled,
      savingsGoal,
      onboardingCompleted,
      borderColor,
      themeMode,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSettings &&
          other.id == this.id &&
          other.userName == this.userName &&
          other.currency == this.currency &&
          other.financialCycle == this.financialCycle &&
          other.transportMode == this.transportMode &&
          other.dailyTransportCost == this.dailyTransportCost &&
          other.transportDaysPerWeek == this.transportDaysPerWeek &&
          other.fixedTransportAmount == this.fixedTransportAmount &&
          other.biometricEnabled == this.biometricEnabled &&
          other.pinEnabled == this.pinEnabled &&
          other.discreteModeEnabled == this.discreteModeEnabled &&
          other.smsParsingEnabled == this.smsParsingEnabled &&
          other.savingsGoal == this.savingsGoal &&
          other.onboardingCompleted == this.onboardingCompleted &&
          other.borderColor == this.borderColor &&
          other.themeMode == this.themeMode &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SettingsCompanion extends UpdateCompanion<UserSettings> {
  final Value<int> id;
  final Value<String> userName;
  final Value<String> currency;
  final Value<FinancialCycle> financialCycle;
  final Value<TransportMode> transportMode;
  final Value<double?> dailyTransportCost;
  final Value<int?> transportDaysPerWeek;
  final Value<double?> fixedTransportAmount;
  final Value<bool> biometricEnabled;
  final Value<bool> pinEnabled;
  final Value<bool> discreteModeEnabled;
  final Value<bool> smsParsingEnabled;
  final Value<double> savingsGoal;
  final Value<bool> onboardingCompleted;
  final Value<String?> borderColor;
  final Value<ThemeModePreference> themeMode;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.userName = const Value.absent(),
    this.currency = const Value.absent(),
    this.financialCycle = const Value.absent(),
    this.transportMode = const Value.absent(),
    this.dailyTransportCost = const Value.absent(),
    this.transportDaysPerWeek = const Value.absent(),
    this.fixedTransportAmount = const Value.absent(),
    this.biometricEnabled = const Value.absent(),
    this.pinEnabled = const Value.absent(),
    this.discreteModeEnabled = const Value.absent(),
    this.smsParsingEnabled = const Value.absent(),
    this.savingsGoal = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.borderColor = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    required String userName,
    this.currency = const Value.absent(),
    required FinancialCycle financialCycle,
    required TransportMode transportMode,
    this.dailyTransportCost = const Value.absent(),
    this.transportDaysPerWeek = const Value.absent(),
    this.fixedTransportAmount = const Value.absent(),
    this.biometricEnabled = const Value.absent(),
    this.pinEnabled = const Value.absent(),
    this.discreteModeEnabled = const Value.absent(),
    this.smsParsingEnabled = const Value.absent(),
    this.savingsGoal = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.borderColor = const Value.absent(),
    this.themeMode = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : userName = Value(userName),
        financialCycle = Value(financialCycle),
        transportMode = Value(transportMode),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<UserSettings> custom({
    Expression<int>? id,
    Expression<String>? userName,
    Expression<String>? currency,
    Expression<int>? financialCycle,
    Expression<int>? transportMode,
    Expression<double>? dailyTransportCost,
    Expression<int>? transportDaysPerWeek,
    Expression<double>? fixedTransportAmount,
    Expression<bool>? biometricEnabled,
    Expression<bool>? pinEnabled,
    Expression<bool>? discreteModeEnabled,
    Expression<bool>? smsParsingEnabled,
    Expression<double>? savingsGoal,
    Expression<bool>? onboardingCompleted,
    Expression<String>? borderColor,
    Expression<int>? themeMode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userName != null) 'user_name': userName,
      if (currency != null) 'currency': currency,
      if (financialCycle != null) 'financial_cycle': financialCycle,
      if (transportMode != null) 'transport_mode': transportMode,
      if (dailyTransportCost != null)
        'daily_transport_cost': dailyTransportCost,
      if (transportDaysPerWeek != null)
        'transport_days_per_week': transportDaysPerWeek,
      if (fixedTransportAmount != null)
        'fixed_transport_amount': fixedTransportAmount,
      if (biometricEnabled != null) 'biometric_enabled': biometricEnabled,
      if (pinEnabled != null) 'pin_enabled': pinEnabled,
      if (discreteModeEnabled != null)
        'discrete_mode_enabled': discreteModeEnabled,
      if (smsParsingEnabled != null) 'sms_parsing_enabled': smsParsingEnabled,
      if (savingsGoal != null) 'savings_goal': savingsGoal,
      if (onboardingCompleted != null)
        'onboarding_completed': onboardingCompleted,
      if (borderColor != null) 'border_color': borderColor,
      if (themeMode != null) 'theme_mode': themeMode,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SettingsCompanion copyWith(
      {Value<int>? id,
      Value<String>? userName,
      Value<String>? currency,
      Value<FinancialCycle>? financialCycle,
      Value<TransportMode>? transportMode,
      Value<double?>? dailyTransportCost,
      Value<int?>? transportDaysPerWeek,
      Value<double?>? fixedTransportAmount,
      Value<bool>? biometricEnabled,
      Value<bool>? pinEnabled,
      Value<bool>? discreteModeEnabled,
      Value<bool>? smsParsingEnabled,
      Value<double>? savingsGoal,
      Value<bool>? onboardingCompleted,
      Value<String?>? borderColor,
      Value<ThemeModePreference>? themeMode,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return SettingsCompanion(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      currency: currency ?? this.currency,
      financialCycle: financialCycle ?? this.financialCycle,
      transportMode: transportMode ?? this.transportMode,
      dailyTransportCost: dailyTransportCost ?? this.dailyTransportCost,
      transportDaysPerWeek: transportDaysPerWeek ?? this.transportDaysPerWeek,
      fixedTransportAmount: fixedTransportAmount ?? this.fixedTransportAmount,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      pinEnabled: pinEnabled ?? this.pinEnabled,
      discreteModeEnabled: discreteModeEnabled ?? this.discreteModeEnabled,
      smsParsingEnabled: smsParsingEnabled ?? this.smsParsingEnabled,
      savingsGoal: savingsGoal ?? this.savingsGoal,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      borderColor: borderColor ?? this.borderColor,
      themeMode: themeMode ?? this.themeMode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userName.present) {
      map['user_name'] = Variable<String>(userName.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (financialCycle.present) {
      map['financial_cycle'] = Variable<int>(
          $SettingsTable.$converterfinancialCycle.toSql(financialCycle.value));
    }
    if (transportMode.present) {
      map['transport_mode'] = Variable<int>(
          $SettingsTable.$convertertransportMode.toSql(transportMode.value));
    }
    if (dailyTransportCost.present) {
      map['daily_transport_cost'] = Variable<double>(dailyTransportCost.value);
    }
    if (transportDaysPerWeek.present) {
      map['transport_days_per_week'] =
          Variable<int>(transportDaysPerWeek.value);
    }
    if (fixedTransportAmount.present) {
      map['fixed_transport_amount'] =
          Variable<double>(fixedTransportAmount.value);
    }
    if (biometricEnabled.present) {
      map['biometric_enabled'] = Variable<bool>(biometricEnabled.value);
    }
    if (pinEnabled.present) {
      map['pin_enabled'] = Variable<bool>(pinEnabled.value);
    }
    if (discreteModeEnabled.present) {
      map['discrete_mode_enabled'] = Variable<bool>(discreteModeEnabled.value);
    }
    if (smsParsingEnabled.present) {
      map['sms_parsing_enabled'] = Variable<bool>(smsParsingEnabled.value);
    }
    if (savingsGoal.present) {
      map['savings_goal'] = Variable<double>(savingsGoal.value);
    }
    if (onboardingCompleted.present) {
      map['onboarding_completed'] = Variable<bool>(onboardingCompleted.value);
    }
    if (borderColor.present) {
      map['border_color'] = Variable<String>(borderColor.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<int>(
          $SettingsTable.$converterthemeMode.toSql(themeMode.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('userName: $userName, ')
          ..write('currency: $currency, ')
          ..write('financialCycle: $financialCycle, ')
          ..write('transportMode: $transportMode, ')
          ..write('dailyTransportCost: $dailyTransportCost, ')
          ..write('transportDaysPerWeek: $transportDaysPerWeek, ')
          ..write('fixedTransportAmount: $fixedTransportAmount, ')
          ..write('biometricEnabled: $biometricEnabled, ')
          ..write('pinEnabled: $pinEnabled, ')
          ..write('discreteModeEnabled: $discreteModeEnabled, ')
          ..write('smsParsingEnabled: $smsParsingEnabled, ')
          ..write('savingsGoal: $savingsGoal, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('borderColor: $borderColor, ')
          ..write('themeMode: $themeMode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $IncomePatternsTable extends IncomePatterns
    with TableInfo<$IncomePatternsTable, IncomePattern> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncomePatternsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _estimatedWeeklyIncomeMeta =
      const VerificationMeta('estimatedWeeklyIncome');
  @override
  late final GeneratedColumn<double> estimatedWeeklyIncome =
      GeneratedColumn<double>('estimated_weekly_income', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _minimumObservedMeta =
      const VerificationMeta('minimumObserved');
  @override
  late final GeneratedColumn<double> minimumObserved = GeneratedColumn<double>(
      'minimum_observed', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _maximumObservedMeta =
      const VerificationMeta('maximumObserved');
  @override
  late final GeneratedColumn<double> maximumObserved = GeneratedColumn<double>(
      'maximum_observed', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _averageObservedMeta =
      const VerificationMeta('averageObserved');
  @override
  late final GeneratedColumn<double> averageObserved = GeneratedColumn<double>(
      'average_observed', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _varianceMeta =
      const VerificationMeta('variance');
  @override
  late final GeneratedColumn<double> variance = GeneratedColumn<double>(
      'variance', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _isRegularMeta =
      const VerificationMeta('isRegular');
  @override
  late final GeneratedColumn<bool> isRegular = GeneratedColumn<bool>(
      'is_regular', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_regular" IN (0, 1))'));
  static const VerificationMeta _transactionCountMeta =
      const VerificationMeta('transactionCount');
  @override
  late final GeneratedColumn<int> transactionCount = GeneratedColumn<int>(
      'transaction_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _analysisWindowDaysMeta =
      const VerificationMeta('analysisWindowDays');
  @override
  late final GeneratedColumn<int> analysisWindowDays = GeneratedColumn<int>(
      'analysis_window_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(90));
  static const VerificationMeta _frequencyMeta =
      const VerificationMeta('frequency');
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
      'frequency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nextPredictedDateMeta =
      const VerificationMeta('nextPredictedDate');
  @override
  late final GeneratedColumn<DateTime> nextPredictedDate =
      GeneratedColumn<DateTime>('next_predicted_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        estimatedWeeklyIncome,
        minimumObserved,
        maximumObserved,
        averageObserved,
        variance,
        isRegular,
        transactionCount,
        analysisWindowDays,
        frequency,
        nextPredictedDate,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'income_patterns';
  @override
  VerificationContext validateIntegrity(Insertable<IncomePattern> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('estimated_weekly_income')) {
      context.handle(
          _estimatedWeeklyIncomeMeta,
          estimatedWeeklyIncome.isAcceptableOrUnknown(
              data['estimated_weekly_income']!, _estimatedWeeklyIncomeMeta));
    } else if (isInserting) {
      context.missing(_estimatedWeeklyIncomeMeta);
    }
    if (data.containsKey('minimum_observed')) {
      context.handle(
          _minimumObservedMeta,
          minimumObserved.isAcceptableOrUnknown(
              data['minimum_observed']!, _minimumObservedMeta));
    } else if (isInserting) {
      context.missing(_minimumObservedMeta);
    }
    if (data.containsKey('maximum_observed')) {
      context.handle(
          _maximumObservedMeta,
          maximumObserved.isAcceptableOrUnknown(
              data['maximum_observed']!, _maximumObservedMeta));
    } else if (isInserting) {
      context.missing(_maximumObservedMeta);
    }
    if (data.containsKey('average_observed')) {
      context.handle(
          _averageObservedMeta,
          averageObserved.isAcceptableOrUnknown(
              data['average_observed']!, _averageObservedMeta));
    } else if (isInserting) {
      context.missing(_averageObservedMeta);
    }
    if (data.containsKey('variance')) {
      context.handle(_varianceMeta,
          variance.isAcceptableOrUnknown(data['variance']!, _varianceMeta));
    } else if (isInserting) {
      context.missing(_varianceMeta);
    }
    if (data.containsKey('is_regular')) {
      context.handle(_isRegularMeta,
          isRegular.isAcceptableOrUnknown(data['is_regular']!, _isRegularMeta));
    } else if (isInserting) {
      context.missing(_isRegularMeta);
    }
    if (data.containsKey('transaction_count')) {
      context.handle(
          _transactionCountMeta,
          transactionCount.isAcceptableOrUnknown(
              data['transaction_count']!, _transactionCountMeta));
    } else if (isInserting) {
      context.missing(_transactionCountMeta);
    }
    if (data.containsKey('analysis_window_days')) {
      context.handle(
          _analysisWindowDaysMeta,
          analysisWindowDays.isAcceptableOrUnknown(
              data['analysis_window_days']!, _analysisWindowDaysMeta));
    }
    if (data.containsKey('frequency')) {
      context.handle(_frequencyMeta,
          frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta));
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('next_predicted_date')) {
      context.handle(
          _nextPredictedDateMeta,
          nextPredictedDate.isAcceptableOrUnknown(
              data['next_predicted_date']!, _nextPredictedDateMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IncomePattern map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IncomePattern(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      estimatedWeeklyIncome: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}estimated_weekly_income'])!,
      minimumObserved: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}minimum_observed'])!,
      maximumObserved: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}maximum_observed'])!,
      averageObserved: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}average_observed'])!,
      variance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}variance'])!,
      isRegular: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_regular'])!,
      transactionCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}transaction_count'])!,
      analysisWindowDays: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}analysis_window_days'])!,
      frequency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}frequency'])!,
      nextPredictedDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_predicted_date']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $IncomePatternsTable createAlias(String alias) {
    return $IncomePatternsTable(attachedDatabase, alias);
  }
}

class IncomePattern extends DataClass implements Insertable<IncomePattern> {
  final int id;
  final double estimatedWeeklyIncome;
  final double minimumObserved;
  final double maximumObserved;
  final double averageObserved;
  final double variance;
  final bool isRegular;
  final int transactionCount;
  final int analysisWindowDays;
  final String frequency;
  final DateTime? nextPredictedDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  const IncomePattern(
      {required this.id,
      required this.estimatedWeeklyIncome,
      required this.minimumObserved,
      required this.maximumObserved,
      required this.averageObserved,
      required this.variance,
      required this.isRegular,
      required this.transactionCount,
      required this.analysisWindowDays,
      required this.frequency,
      this.nextPredictedDate,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['estimated_weekly_income'] = Variable<double>(estimatedWeeklyIncome);
    map['minimum_observed'] = Variable<double>(minimumObserved);
    map['maximum_observed'] = Variable<double>(maximumObserved);
    map['average_observed'] = Variable<double>(averageObserved);
    map['variance'] = Variable<double>(variance);
    map['is_regular'] = Variable<bool>(isRegular);
    map['transaction_count'] = Variable<int>(transactionCount);
    map['analysis_window_days'] = Variable<int>(analysisWindowDays);
    map['frequency'] = Variable<String>(frequency);
    if (!nullToAbsent || nextPredictedDate != null) {
      map['next_predicted_date'] = Variable<DateTime>(nextPredictedDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  IncomePatternsCompanion toCompanion(bool nullToAbsent) {
    return IncomePatternsCompanion(
      id: Value(id),
      estimatedWeeklyIncome: Value(estimatedWeeklyIncome),
      minimumObserved: Value(minimumObserved),
      maximumObserved: Value(maximumObserved),
      averageObserved: Value(averageObserved),
      variance: Value(variance),
      isRegular: Value(isRegular),
      transactionCount: Value(transactionCount),
      analysisWindowDays: Value(analysisWindowDays),
      frequency: Value(frequency),
      nextPredictedDate: nextPredictedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(nextPredictedDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory IncomePattern.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IncomePattern(
      id: serializer.fromJson<int>(json['id']),
      estimatedWeeklyIncome:
          serializer.fromJson<double>(json['estimatedWeeklyIncome']),
      minimumObserved: serializer.fromJson<double>(json['minimumObserved']),
      maximumObserved: serializer.fromJson<double>(json['maximumObserved']),
      averageObserved: serializer.fromJson<double>(json['averageObserved']),
      variance: serializer.fromJson<double>(json['variance']),
      isRegular: serializer.fromJson<bool>(json['isRegular']),
      transactionCount: serializer.fromJson<int>(json['transactionCount']),
      analysisWindowDays: serializer.fromJson<int>(json['analysisWindowDays']),
      frequency: serializer.fromJson<String>(json['frequency']),
      nextPredictedDate:
          serializer.fromJson<DateTime?>(json['nextPredictedDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'estimatedWeeklyIncome': serializer.toJson<double>(estimatedWeeklyIncome),
      'minimumObserved': serializer.toJson<double>(minimumObserved),
      'maximumObserved': serializer.toJson<double>(maximumObserved),
      'averageObserved': serializer.toJson<double>(averageObserved),
      'variance': serializer.toJson<double>(variance),
      'isRegular': serializer.toJson<bool>(isRegular),
      'transactionCount': serializer.toJson<int>(transactionCount),
      'analysisWindowDays': serializer.toJson<int>(analysisWindowDays),
      'frequency': serializer.toJson<String>(frequency),
      'nextPredictedDate': serializer.toJson<DateTime?>(nextPredictedDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  IncomePattern copyWith(
          {int? id,
          double? estimatedWeeklyIncome,
          double? minimumObserved,
          double? maximumObserved,
          double? averageObserved,
          double? variance,
          bool? isRegular,
          int? transactionCount,
          int? analysisWindowDays,
          String? frequency,
          Value<DateTime?> nextPredictedDate = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      IncomePattern(
        id: id ?? this.id,
        estimatedWeeklyIncome:
            estimatedWeeklyIncome ?? this.estimatedWeeklyIncome,
        minimumObserved: minimumObserved ?? this.minimumObserved,
        maximumObserved: maximumObserved ?? this.maximumObserved,
        averageObserved: averageObserved ?? this.averageObserved,
        variance: variance ?? this.variance,
        isRegular: isRegular ?? this.isRegular,
        transactionCount: transactionCount ?? this.transactionCount,
        analysisWindowDays: analysisWindowDays ?? this.analysisWindowDays,
        frequency: frequency ?? this.frequency,
        nextPredictedDate: nextPredictedDate.present
            ? nextPredictedDate.value
            : this.nextPredictedDate,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  IncomePattern copyWithCompanion(IncomePatternsCompanion data) {
    return IncomePattern(
      id: data.id.present ? data.id.value : this.id,
      estimatedWeeklyIncome: data.estimatedWeeklyIncome.present
          ? data.estimatedWeeklyIncome.value
          : this.estimatedWeeklyIncome,
      minimumObserved: data.minimumObserved.present
          ? data.minimumObserved.value
          : this.minimumObserved,
      maximumObserved: data.maximumObserved.present
          ? data.maximumObserved.value
          : this.maximumObserved,
      averageObserved: data.averageObserved.present
          ? data.averageObserved.value
          : this.averageObserved,
      variance: data.variance.present ? data.variance.value : this.variance,
      isRegular: data.isRegular.present ? data.isRegular.value : this.isRegular,
      transactionCount: data.transactionCount.present
          ? data.transactionCount.value
          : this.transactionCount,
      analysisWindowDays: data.analysisWindowDays.present
          ? data.analysisWindowDays.value
          : this.analysisWindowDays,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      nextPredictedDate: data.nextPredictedDate.present
          ? data.nextPredictedDate.value
          : this.nextPredictedDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IncomePattern(')
          ..write('id: $id, ')
          ..write('estimatedWeeklyIncome: $estimatedWeeklyIncome, ')
          ..write('minimumObserved: $minimumObserved, ')
          ..write('maximumObserved: $maximumObserved, ')
          ..write('averageObserved: $averageObserved, ')
          ..write('variance: $variance, ')
          ..write('isRegular: $isRegular, ')
          ..write('transactionCount: $transactionCount, ')
          ..write('analysisWindowDays: $analysisWindowDays, ')
          ..write('frequency: $frequency, ')
          ..write('nextPredictedDate: $nextPredictedDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      estimatedWeeklyIncome,
      minimumObserved,
      maximumObserved,
      averageObserved,
      variance,
      isRegular,
      transactionCount,
      analysisWindowDays,
      frequency,
      nextPredictedDate,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IncomePattern &&
          other.id == this.id &&
          other.estimatedWeeklyIncome == this.estimatedWeeklyIncome &&
          other.minimumObserved == this.minimumObserved &&
          other.maximumObserved == this.maximumObserved &&
          other.averageObserved == this.averageObserved &&
          other.variance == this.variance &&
          other.isRegular == this.isRegular &&
          other.transactionCount == this.transactionCount &&
          other.analysisWindowDays == this.analysisWindowDays &&
          other.frequency == this.frequency &&
          other.nextPredictedDate == this.nextPredictedDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class IncomePatternsCompanion extends UpdateCompanion<IncomePattern> {
  final Value<int> id;
  final Value<double> estimatedWeeklyIncome;
  final Value<double> minimumObserved;
  final Value<double> maximumObserved;
  final Value<double> averageObserved;
  final Value<double> variance;
  final Value<bool> isRegular;
  final Value<int> transactionCount;
  final Value<int> analysisWindowDays;
  final Value<String> frequency;
  final Value<DateTime?> nextPredictedDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const IncomePatternsCompanion({
    this.id = const Value.absent(),
    this.estimatedWeeklyIncome = const Value.absent(),
    this.minimumObserved = const Value.absent(),
    this.maximumObserved = const Value.absent(),
    this.averageObserved = const Value.absent(),
    this.variance = const Value.absent(),
    this.isRegular = const Value.absent(),
    this.transactionCount = const Value.absent(),
    this.analysisWindowDays = const Value.absent(),
    this.frequency = const Value.absent(),
    this.nextPredictedDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  IncomePatternsCompanion.insert({
    this.id = const Value.absent(),
    required double estimatedWeeklyIncome,
    required double minimumObserved,
    required double maximumObserved,
    required double averageObserved,
    required double variance,
    required bool isRegular,
    required int transactionCount,
    this.analysisWindowDays = const Value.absent(),
    required String frequency,
    this.nextPredictedDate = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : estimatedWeeklyIncome = Value(estimatedWeeklyIncome),
        minimumObserved = Value(minimumObserved),
        maximumObserved = Value(maximumObserved),
        averageObserved = Value(averageObserved),
        variance = Value(variance),
        isRegular = Value(isRegular),
        transactionCount = Value(transactionCount),
        frequency = Value(frequency),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<IncomePattern> custom({
    Expression<int>? id,
    Expression<double>? estimatedWeeklyIncome,
    Expression<double>? minimumObserved,
    Expression<double>? maximumObserved,
    Expression<double>? averageObserved,
    Expression<double>? variance,
    Expression<bool>? isRegular,
    Expression<int>? transactionCount,
    Expression<int>? analysisWindowDays,
    Expression<String>? frequency,
    Expression<DateTime>? nextPredictedDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (estimatedWeeklyIncome != null)
        'estimated_weekly_income': estimatedWeeklyIncome,
      if (minimumObserved != null) 'minimum_observed': minimumObserved,
      if (maximumObserved != null) 'maximum_observed': maximumObserved,
      if (averageObserved != null) 'average_observed': averageObserved,
      if (variance != null) 'variance': variance,
      if (isRegular != null) 'is_regular': isRegular,
      if (transactionCount != null) 'transaction_count': transactionCount,
      if (analysisWindowDays != null)
        'analysis_window_days': analysisWindowDays,
      if (frequency != null) 'frequency': frequency,
      if (nextPredictedDate != null) 'next_predicted_date': nextPredictedDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  IncomePatternsCompanion copyWith(
      {Value<int>? id,
      Value<double>? estimatedWeeklyIncome,
      Value<double>? minimumObserved,
      Value<double>? maximumObserved,
      Value<double>? averageObserved,
      Value<double>? variance,
      Value<bool>? isRegular,
      Value<int>? transactionCount,
      Value<int>? analysisWindowDays,
      Value<String>? frequency,
      Value<DateTime?>? nextPredictedDate,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return IncomePatternsCompanion(
      id: id ?? this.id,
      estimatedWeeklyIncome:
          estimatedWeeklyIncome ?? this.estimatedWeeklyIncome,
      minimumObserved: minimumObserved ?? this.minimumObserved,
      maximumObserved: maximumObserved ?? this.maximumObserved,
      averageObserved: averageObserved ?? this.averageObserved,
      variance: variance ?? this.variance,
      isRegular: isRegular ?? this.isRegular,
      transactionCount: transactionCount ?? this.transactionCount,
      analysisWindowDays: analysisWindowDays ?? this.analysisWindowDays,
      frequency: frequency ?? this.frequency,
      nextPredictedDate: nextPredictedDate ?? this.nextPredictedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (estimatedWeeklyIncome.present) {
      map['estimated_weekly_income'] =
          Variable<double>(estimatedWeeklyIncome.value);
    }
    if (minimumObserved.present) {
      map['minimum_observed'] = Variable<double>(minimumObserved.value);
    }
    if (maximumObserved.present) {
      map['maximum_observed'] = Variable<double>(maximumObserved.value);
    }
    if (averageObserved.present) {
      map['average_observed'] = Variable<double>(averageObserved.value);
    }
    if (variance.present) {
      map['variance'] = Variable<double>(variance.value);
    }
    if (isRegular.present) {
      map['is_regular'] = Variable<bool>(isRegular.value);
    }
    if (transactionCount.present) {
      map['transaction_count'] = Variable<int>(transactionCount.value);
    }
    if (analysisWindowDays.present) {
      map['analysis_window_days'] = Variable<int>(analysisWindowDays.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (nextPredictedDate.present) {
      map['next_predicted_date'] = Variable<DateTime>(nextPredictedDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncomePatternsCompanion(')
          ..write('id: $id, ')
          ..write('estimatedWeeklyIncome: $estimatedWeeklyIncome, ')
          ..write('minimumObserved: $minimumObserved, ')
          ..write('maximumObserved: $maximumObserved, ')
          ..write('averageObserved: $averageObserved, ')
          ..write('variance: $variance, ')
          ..write('isRegular: $isRegular, ')
          ..write('transactionCount: $transactionCount, ')
          ..write('analysisWindowDays: $analysisWindowDays, ')
          ..write('frequency: $frequency, ')
          ..write('nextPredictedDate: $nextPredictedDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $InsightsTable extends Insights with TableInfo<$InsightsTable, Insight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InsightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalAmountMeta =
      const VerificationMeta('totalAmount');
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
      'total_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _transactionCountMeta =
      const VerificationMeta('transactionCount');
  @override
  late final GeneratedColumn<int> transactionCount = GeneratedColumn<int>(
      'transaction_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _categoryNamesMeta =
      const VerificationMeta('categoryNames');
  @override
  late final GeneratedColumn<String> categoryNames = GeneratedColumn<String>(
      'category_names', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _percentageOfAvailableMeta =
      const VerificationMeta('percentageOfAvailable');
  @override
  late final GeneratedColumn<double> percentageOfAvailable =
      GeneratedColumn<double>('percentage_of_available', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _isDismissedMeta =
      const VerificationMeta('isDismissed');
  @override
  late final GeneratedColumn<bool> isDismissed = GeneratedColumn<bool>(
      'is_dismissed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_dismissed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _detectedAtMeta =
      const VerificationMeta('detectedAt');
  @override
  late final GeneratedColumn<DateTime> detectedAt = GeneratedColumn<DateTime>(
      'detected_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
      'expires_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        totalAmount,
        transactionCount,
        categoryNames,
        percentageOfAvailable,
        isDismissed,
        detectedAt,
        expiresAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'insights';
  @override
  VerificationContext validateIntegrity(Insertable<Insight> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
          _totalAmountMeta,
          totalAmount.isAcceptableOrUnknown(
              data['total_amount']!, _totalAmountMeta));
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('transaction_count')) {
      context.handle(
          _transactionCountMeta,
          transactionCount.isAcceptableOrUnknown(
              data['transaction_count']!, _transactionCountMeta));
    } else if (isInserting) {
      context.missing(_transactionCountMeta);
    }
    if (data.containsKey('category_names')) {
      context.handle(
          _categoryNamesMeta,
          categoryNames.isAcceptableOrUnknown(
              data['category_names']!, _categoryNamesMeta));
    } else if (isInserting) {
      context.missing(_categoryNamesMeta);
    }
    if (data.containsKey('percentage_of_available')) {
      context.handle(
          _percentageOfAvailableMeta,
          percentageOfAvailable.isAcceptableOrUnknown(
              data['percentage_of_available']!, _percentageOfAvailableMeta));
    } else if (isInserting) {
      context.missing(_percentageOfAvailableMeta);
    }
    if (data.containsKey('is_dismissed')) {
      context.handle(
          _isDismissedMeta,
          isDismissed.isAcceptableOrUnknown(
              data['is_dismissed']!, _isDismissedMeta));
    }
    if (data.containsKey('detected_at')) {
      context.handle(
          _detectedAtMeta,
          detectedAt.isAcceptableOrUnknown(
              data['detected_at']!, _detectedAtMeta));
    } else if (isInserting) {
      context.missing(_detectedAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(_expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Insight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Insight(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      totalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_amount'])!,
      transactionCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}transaction_count'])!,
      categoryNames: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_names'])!,
      percentageOfAvailable: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}percentage_of_available'])!,
      isDismissed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dismissed'])!,
      detectedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}detected_at'])!,
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expires_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $InsightsTable createAlias(String alias) {
    return $InsightsTable(attachedDatabase, alias);
  }
}

class Insight extends DataClass implements Insertable<Insight> {
  final int id;
  final String type;
  final double totalAmount;
  final int transactionCount;
  final String categoryNames;
  final double percentageOfAvailable;
  final bool isDismissed;
  final DateTime detectedAt;
  final DateTime expiresAt;
  final DateTime createdAt;
  const Insight(
      {required this.id,
      required this.type,
      required this.totalAmount,
      required this.transactionCount,
      required this.categoryNames,
      required this.percentageOfAvailable,
      required this.isDismissed,
      required this.detectedAt,
      required this.expiresAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['total_amount'] = Variable<double>(totalAmount);
    map['transaction_count'] = Variable<int>(transactionCount);
    map['category_names'] = Variable<String>(categoryNames);
    map['percentage_of_available'] = Variable<double>(percentageOfAvailable);
    map['is_dismissed'] = Variable<bool>(isDismissed);
    map['detected_at'] = Variable<DateTime>(detectedAt);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InsightsCompanion toCompanion(bool nullToAbsent) {
    return InsightsCompanion(
      id: Value(id),
      type: Value(type),
      totalAmount: Value(totalAmount),
      transactionCount: Value(transactionCount),
      categoryNames: Value(categoryNames),
      percentageOfAvailable: Value(percentageOfAvailable),
      isDismissed: Value(isDismissed),
      detectedAt: Value(detectedAt),
      expiresAt: Value(expiresAt),
      createdAt: Value(createdAt),
    );
  }

  factory Insight.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Insight(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      transactionCount: serializer.fromJson<int>(json['transactionCount']),
      categoryNames: serializer.fromJson<String>(json['categoryNames']),
      percentageOfAvailable:
          serializer.fromJson<double>(json['percentageOfAvailable']),
      isDismissed: serializer.fromJson<bool>(json['isDismissed']),
      detectedAt: serializer.fromJson<DateTime>(json['detectedAt']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'transactionCount': serializer.toJson<int>(transactionCount),
      'categoryNames': serializer.toJson<String>(categoryNames),
      'percentageOfAvailable': serializer.toJson<double>(percentageOfAvailable),
      'isDismissed': serializer.toJson<bool>(isDismissed),
      'detectedAt': serializer.toJson<DateTime>(detectedAt),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Insight copyWith(
          {int? id,
          String? type,
          double? totalAmount,
          int? transactionCount,
          String? categoryNames,
          double? percentageOfAvailable,
          bool? isDismissed,
          DateTime? detectedAt,
          DateTime? expiresAt,
          DateTime? createdAt}) =>
      Insight(
        id: id ?? this.id,
        type: type ?? this.type,
        totalAmount: totalAmount ?? this.totalAmount,
        transactionCount: transactionCount ?? this.transactionCount,
        categoryNames: categoryNames ?? this.categoryNames,
        percentageOfAvailable:
            percentageOfAvailable ?? this.percentageOfAvailable,
        isDismissed: isDismissed ?? this.isDismissed,
        detectedAt: detectedAt ?? this.detectedAt,
        expiresAt: expiresAt ?? this.expiresAt,
        createdAt: createdAt ?? this.createdAt,
      );
  Insight copyWithCompanion(InsightsCompanion data) {
    return Insight(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      totalAmount:
          data.totalAmount.present ? data.totalAmount.value : this.totalAmount,
      transactionCount: data.transactionCount.present
          ? data.transactionCount.value
          : this.transactionCount,
      categoryNames: data.categoryNames.present
          ? data.categoryNames.value
          : this.categoryNames,
      percentageOfAvailable: data.percentageOfAvailable.present
          ? data.percentageOfAvailable.value
          : this.percentageOfAvailable,
      isDismissed:
          data.isDismissed.present ? data.isDismissed.value : this.isDismissed,
      detectedAt:
          data.detectedAt.present ? data.detectedAt.value : this.detectedAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Insight(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('transactionCount: $transactionCount, ')
          ..write('categoryNames: $categoryNames, ')
          ..write('percentageOfAvailable: $percentageOfAvailable, ')
          ..write('isDismissed: $isDismissed, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      type,
      totalAmount,
      transactionCount,
      categoryNames,
      percentageOfAvailable,
      isDismissed,
      detectedAt,
      expiresAt,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Insight &&
          other.id == this.id &&
          other.type == this.type &&
          other.totalAmount == this.totalAmount &&
          other.transactionCount == this.transactionCount &&
          other.categoryNames == this.categoryNames &&
          other.percentageOfAvailable == this.percentageOfAvailable &&
          other.isDismissed == this.isDismissed &&
          other.detectedAt == this.detectedAt &&
          other.expiresAt == this.expiresAt &&
          other.createdAt == this.createdAt);
}

class InsightsCompanion extends UpdateCompanion<Insight> {
  final Value<int> id;
  final Value<String> type;
  final Value<double> totalAmount;
  final Value<int> transactionCount;
  final Value<String> categoryNames;
  final Value<double> percentageOfAvailable;
  final Value<bool> isDismissed;
  final Value<DateTime> detectedAt;
  final Value<DateTime> expiresAt;
  final Value<DateTime> createdAt;
  const InsightsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.transactionCount = const Value.absent(),
    this.categoryNames = const Value.absent(),
    this.percentageOfAvailable = const Value.absent(),
    this.isDismissed = const Value.absent(),
    this.detectedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  InsightsCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required double totalAmount,
    required int transactionCount,
    required String categoryNames,
    required double percentageOfAvailable,
    this.isDismissed = const Value.absent(),
    required DateTime detectedAt,
    required DateTime expiresAt,
    required DateTime createdAt,
  })  : type = Value(type),
        totalAmount = Value(totalAmount),
        transactionCount = Value(transactionCount),
        categoryNames = Value(categoryNames),
        percentageOfAvailable = Value(percentageOfAvailable),
        detectedAt = Value(detectedAt),
        expiresAt = Value(expiresAt),
        createdAt = Value(createdAt);
  static Insertable<Insight> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<double>? totalAmount,
    Expression<int>? transactionCount,
    Expression<String>? categoryNames,
    Expression<double>? percentageOfAvailable,
    Expression<bool>? isDismissed,
    Expression<DateTime>? detectedAt,
    Expression<DateTime>? expiresAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (transactionCount != null) 'transaction_count': transactionCount,
      if (categoryNames != null) 'category_names': categoryNames,
      if (percentageOfAvailable != null)
        'percentage_of_available': percentageOfAvailable,
      if (isDismissed != null) 'is_dismissed': isDismissed,
      if (detectedAt != null) 'detected_at': detectedAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  InsightsCompanion copyWith(
      {Value<int>? id,
      Value<String>? type,
      Value<double>? totalAmount,
      Value<int>? transactionCount,
      Value<String>? categoryNames,
      Value<double>? percentageOfAvailable,
      Value<bool>? isDismissed,
      Value<DateTime>? detectedAt,
      Value<DateTime>? expiresAt,
      Value<DateTime>? createdAt}) {
    return InsightsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      totalAmount: totalAmount ?? this.totalAmount,
      transactionCount: transactionCount ?? this.transactionCount,
      categoryNames: categoryNames ?? this.categoryNames,
      percentageOfAvailable:
          percentageOfAvailable ?? this.percentageOfAvailable,
      isDismissed: isDismissed ?? this.isDismissed,
      detectedAt: detectedAt ?? this.detectedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (transactionCount.present) {
      map['transaction_count'] = Variable<int>(transactionCount.value);
    }
    if (categoryNames.present) {
      map['category_names'] = Variable<String>(categoryNames.value);
    }
    if (percentageOfAvailable.present) {
      map['percentage_of_available'] =
          Variable<double>(percentageOfAvailable.value);
    }
    if (isDismissed.present) {
      map['is_dismissed'] = Variable<bool>(isDismissed.value);
    }
    if (detectedAt.present) {
      map['detected_at'] = Variable<DateTime>(detectedAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InsightsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('transactionCount: $transactionCount, ')
          ..write('categoryNames: $categoryNames, ')
          ..write('percentageOfAvailable: $percentageOfAvailable, ')
          ..write('isDismissed: $isDismissed, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BehavioralProfilesTable extends BehavioralProfiles
    with TableInfo<$BehavioralProfilesTable, BehavioralProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BehavioralProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _spendingFrequencyMeta =
      const VerificationMeta('spendingFrequency');
  @override
  late final GeneratedColumn<double> spendingFrequency =
      GeneratedColumn<double>('spending_frequency', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _hourlyPatternMeta =
      const VerificationMeta('hourlyPattern');
  @override
  late final GeneratedColumn<String> hourlyPattern = GeneratedColumn<String>(
      'hourly_pattern', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _overrunCountMeta =
      const VerificationMeta('overrunCount');
  @override
  late final GeneratedColumn<int> overrunCount = GeneratedColumn<int>(
      'overrun_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _averageOverrunMeta =
      const VerificationMeta('averageOverrun');
  @override
  late final GeneratedColumn<double> averageOverrun = GeneratedColumn<double>(
      'average_overrun', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _advisoryLevelMeta =
      const VerificationMeta('advisoryLevel');
  @override
  late final GeneratedColumn<String> advisoryLevel = GeneratedColumn<String>(
      'advisory_level', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        spendingFrequency,
        hourlyPattern,
        overrunCount,
        averageOverrun,
        advisoryLevel,
        lastUpdated,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'behavioral_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<BehavioralProfile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('spending_frequency')) {
      context.handle(
          _spendingFrequencyMeta,
          spendingFrequency.isAcceptableOrUnknown(
              data['spending_frequency']!, _spendingFrequencyMeta));
    } else if (isInserting) {
      context.missing(_spendingFrequencyMeta);
    }
    if (data.containsKey('hourly_pattern')) {
      context.handle(
          _hourlyPatternMeta,
          hourlyPattern.isAcceptableOrUnknown(
              data['hourly_pattern']!, _hourlyPatternMeta));
    } else if (isInserting) {
      context.missing(_hourlyPatternMeta);
    }
    if (data.containsKey('overrun_count')) {
      context.handle(
          _overrunCountMeta,
          overrunCount.isAcceptableOrUnknown(
              data['overrun_count']!, _overrunCountMeta));
    } else if (isInserting) {
      context.missing(_overrunCountMeta);
    }
    if (data.containsKey('average_overrun')) {
      context.handle(
          _averageOverrunMeta,
          averageOverrun.isAcceptableOrUnknown(
              data['average_overrun']!, _averageOverrunMeta));
    } else if (isInserting) {
      context.missing(_averageOverrunMeta);
    }
    if (data.containsKey('advisory_level')) {
      context.handle(
          _advisoryLevelMeta,
          advisoryLevel.isAcceptableOrUnknown(
              data['advisory_level']!, _advisoryLevelMeta));
    } else if (isInserting) {
      context.missing(_advisoryLevelMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    } else if (isInserting) {
      context.missing(_lastUpdatedMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BehavioralProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BehavioralProfile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      spendingFrequency: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}spending_frequency'])!,
      hourlyPattern: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hourly_pattern'])!,
      overrunCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}overrun_count'])!,
      averageOverrun: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}average_overrun'])!,
      advisoryLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}advisory_level'])!,
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BehavioralProfilesTable createAlias(String alias) {
    return $BehavioralProfilesTable(attachedDatabase, alias);
  }
}

class BehavioralProfile extends DataClass
    implements Insertable<BehavioralProfile> {
  final int id;
  final double spendingFrequency;
  final String hourlyPattern;
  final int overrunCount;
  final double averageOverrun;
  final String advisoryLevel;
  final DateTime lastUpdated;
  final DateTime createdAt;
  const BehavioralProfile(
      {required this.id,
      required this.spendingFrequency,
      required this.hourlyPattern,
      required this.overrunCount,
      required this.averageOverrun,
      required this.advisoryLevel,
      required this.lastUpdated,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['spending_frequency'] = Variable<double>(spendingFrequency);
    map['hourly_pattern'] = Variable<String>(hourlyPattern);
    map['overrun_count'] = Variable<int>(overrunCount);
    map['average_overrun'] = Variable<double>(averageOverrun);
    map['advisory_level'] = Variable<String>(advisoryLevel);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BehavioralProfilesCompanion toCompanion(bool nullToAbsent) {
    return BehavioralProfilesCompanion(
      id: Value(id),
      spendingFrequency: Value(spendingFrequency),
      hourlyPattern: Value(hourlyPattern),
      overrunCount: Value(overrunCount),
      averageOverrun: Value(averageOverrun),
      advisoryLevel: Value(advisoryLevel),
      lastUpdated: Value(lastUpdated),
      createdAt: Value(createdAt),
    );
  }

  factory BehavioralProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BehavioralProfile(
      id: serializer.fromJson<int>(json['id']),
      spendingFrequency: serializer.fromJson<double>(json['spendingFrequency']),
      hourlyPattern: serializer.fromJson<String>(json['hourlyPattern']),
      overrunCount: serializer.fromJson<int>(json['overrunCount']),
      averageOverrun: serializer.fromJson<double>(json['averageOverrun']),
      advisoryLevel: serializer.fromJson<String>(json['advisoryLevel']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'spendingFrequency': serializer.toJson<double>(spendingFrequency),
      'hourlyPattern': serializer.toJson<String>(hourlyPattern),
      'overrunCount': serializer.toJson<int>(overrunCount),
      'averageOverrun': serializer.toJson<double>(averageOverrun),
      'advisoryLevel': serializer.toJson<String>(advisoryLevel),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BehavioralProfile copyWith(
          {int? id,
          double? spendingFrequency,
          String? hourlyPattern,
          int? overrunCount,
          double? averageOverrun,
          String? advisoryLevel,
          DateTime? lastUpdated,
          DateTime? createdAt}) =>
      BehavioralProfile(
        id: id ?? this.id,
        spendingFrequency: spendingFrequency ?? this.spendingFrequency,
        hourlyPattern: hourlyPattern ?? this.hourlyPattern,
        overrunCount: overrunCount ?? this.overrunCount,
        averageOverrun: averageOverrun ?? this.averageOverrun,
        advisoryLevel: advisoryLevel ?? this.advisoryLevel,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        createdAt: createdAt ?? this.createdAt,
      );
  BehavioralProfile copyWithCompanion(BehavioralProfilesCompanion data) {
    return BehavioralProfile(
      id: data.id.present ? data.id.value : this.id,
      spendingFrequency: data.spendingFrequency.present
          ? data.spendingFrequency.value
          : this.spendingFrequency,
      hourlyPattern: data.hourlyPattern.present
          ? data.hourlyPattern.value
          : this.hourlyPattern,
      overrunCount: data.overrunCount.present
          ? data.overrunCount.value
          : this.overrunCount,
      averageOverrun: data.averageOverrun.present
          ? data.averageOverrun.value
          : this.averageOverrun,
      advisoryLevel: data.advisoryLevel.present
          ? data.advisoryLevel.value
          : this.advisoryLevel,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BehavioralProfile(')
          ..write('id: $id, ')
          ..write('spendingFrequency: $spendingFrequency, ')
          ..write('hourlyPattern: $hourlyPattern, ')
          ..write('overrunCount: $overrunCount, ')
          ..write('averageOverrun: $averageOverrun, ')
          ..write('advisoryLevel: $advisoryLevel, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, spendingFrequency, hourlyPattern,
      overrunCount, averageOverrun, advisoryLevel, lastUpdated, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BehavioralProfile &&
          other.id == this.id &&
          other.spendingFrequency == this.spendingFrequency &&
          other.hourlyPattern == this.hourlyPattern &&
          other.overrunCount == this.overrunCount &&
          other.averageOverrun == this.averageOverrun &&
          other.advisoryLevel == this.advisoryLevel &&
          other.lastUpdated == this.lastUpdated &&
          other.createdAt == this.createdAt);
}

class BehavioralProfilesCompanion extends UpdateCompanion<BehavioralProfile> {
  final Value<int> id;
  final Value<double> spendingFrequency;
  final Value<String> hourlyPattern;
  final Value<int> overrunCount;
  final Value<double> averageOverrun;
  final Value<String> advisoryLevel;
  final Value<DateTime> lastUpdated;
  final Value<DateTime> createdAt;
  const BehavioralProfilesCompanion({
    this.id = const Value.absent(),
    this.spendingFrequency = const Value.absent(),
    this.hourlyPattern = const Value.absent(),
    this.overrunCount = const Value.absent(),
    this.averageOverrun = const Value.absent(),
    this.advisoryLevel = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BehavioralProfilesCompanion.insert({
    this.id = const Value.absent(),
    required double spendingFrequency,
    required String hourlyPattern,
    required int overrunCount,
    required double averageOverrun,
    required String advisoryLevel,
    required DateTime lastUpdated,
    required DateTime createdAt,
  })  : spendingFrequency = Value(spendingFrequency),
        hourlyPattern = Value(hourlyPattern),
        overrunCount = Value(overrunCount),
        averageOverrun = Value(averageOverrun),
        advisoryLevel = Value(advisoryLevel),
        lastUpdated = Value(lastUpdated),
        createdAt = Value(createdAt);
  static Insertable<BehavioralProfile> custom({
    Expression<int>? id,
    Expression<double>? spendingFrequency,
    Expression<String>? hourlyPattern,
    Expression<int>? overrunCount,
    Expression<double>? averageOverrun,
    Expression<String>? advisoryLevel,
    Expression<DateTime>? lastUpdated,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spendingFrequency != null) 'spending_frequency': spendingFrequency,
      if (hourlyPattern != null) 'hourly_pattern': hourlyPattern,
      if (overrunCount != null) 'overrun_count': overrunCount,
      if (averageOverrun != null) 'average_overrun': averageOverrun,
      if (advisoryLevel != null) 'advisory_level': advisoryLevel,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BehavioralProfilesCompanion copyWith(
      {Value<int>? id,
      Value<double>? spendingFrequency,
      Value<String>? hourlyPattern,
      Value<int>? overrunCount,
      Value<double>? averageOverrun,
      Value<String>? advisoryLevel,
      Value<DateTime>? lastUpdated,
      Value<DateTime>? createdAt}) {
    return BehavioralProfilesCompanion(
      id: id ?? this.id,
      spendingFrequency: spendingFrequency ?? this.spendingFrequency,
      hourlyPattern: hourlyPattern ?? this.hourlyPattern,
      overrunCount: overrunCount ?? this.overrunCount,
      averageOverrun: averageOverrun ?? this.averageOverrun,
      advisoryLevel: advisoryLevel ?? this.advisoryLevel,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (spendingFrequency.present) {
      map['spending_frequency'] = Variable<double>(spendingFrequency.value);
    }
    if (hourlyPattern.present) {
      map['hourly_pattern'] = Variable<String>(hourlyPattern.value);
    }
    if (overrunCount.present) {
      map['overrun_count'] = Variable<int>(overrunCount.value);
    }
    if (averageOverrun.present) {
      map['average_overrun'] = Variable<double>(averageOverrun.value);
    }
    if (advisoryLevel.present) {
      map['advisory_level'] = Variable<String>(advisoryLevel.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BehavioralProfilesCompanion(')
          ..write('id: $id, ')
          ..write('spendingFrequency: $spendingFrequency, ')
          ..write('hourlyPattern: $hourlyPattern, ')
          ..write('overrunCount: $overrunCount, ')
          ..write('averageOverrun: $averageOverrun, ')
          ..write('advisoryLevel: $advisoryLevel, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  _$AppDatabase.connect(DatabaseConnection c) : super.connect(c);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $RecurringChargesTable recurringCharges =
      $RecurringChargesTable(this);
  late final $PendingTransactionsTable pendingTransactions =
      $PendingTransactionsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $IncomePatternsTable incomePatterns = $IncomePatternsTable(this);
  late final $InsightsTable insights = $InsightsTable(this);
  late final $BehavioralProfilesTable behavioralProfiles =
      $BehavioralProfilesTable(this);
  late final AccountsDao accountsDao = AccountsDao(this as AppDatabase);
  late final TransactionsDao transactionsDao =
      TransactionsDao(this as AppDatabase);
  late final CategoriesDao categoriesDao = CategoriesDao(this as AppDatabase);
  late final RecurringChargesDao recurringChargesDao =
      RecurringChargesDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        accounts,
        categories,
        transactions,
        recurringCharges,
        pendingTransactions,
        settings,
        incomePatterns,
        insights,
        behavioralProfiles
      ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  Value<int> id,
  required String name,
  required AccountType type,
  Value<double> currentBalance,
  required String icon,
  required String color,
  Value<String?> operator,
  Value<bool> isActive,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<AccountType> type,
  Value<double> currentBalance,
  Value<String> icon,
  Value<String> color,
  Value<String?> operator,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$AccountsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountsTable, Account> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PendingTransactionsTable,
      List<PendingTransaction>> _pendingTransactionsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.pendingTransactions,
          aliasName: $_aliasNameGenerator(
              db.accounts.id, db.pendingTransactions.suggestedAccountId));

  $$PendingTransactionsTableProcessedTableManager get pendingTransactionsRefs {
    final manager = $$PendingTransactionsTableTableManager(
            $_db, $_db.pendingTransactions)
        .filter(
            (f) => f.suggestedAccountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_pendingTransactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<AccountType, AccountType, int> get type =>
      $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get currentBalance => $composableBuilder(
      column: $table.currentBalance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operator => $composableBuilder(
      column: $table.operator, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> pendingTransactionsRefs(
      Expression<bool> Function($$PendingTransactionsTableFilterComposer f) f) {
    final $$PendingTransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pendingTransactions,
        getReferencedColumn: (t) => t.suggestedAccountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PendingTransactionsTableFilterComposer(
              $db: $db,
              $table: $db.pendingTransactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get currentBalance => $composableBuilder(
      column: $table.currentBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operator => $composableBuilder(
      column: $table.operator, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<AccountType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get currentBalance => $composableBuilder(
      column: $table.currentBalance, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get operator =>
      $composableBuilder(column: $table.operator, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> pendingTransactionsRefs<T extends Object>(
      Expression<T> Function($$PendingTransactionsTableAnnotationComposer a)
          f) {
    final $$PendingTransactionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.pendingTransactions,
            getReferencedColumn: (t) => t.suggestedAccountId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PendingTransactionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.pendingTransactions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$AccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, $$AccountsTableReferences),
    Account,
    PrefetchHooks Function({bool pendingTransactionsRefs})> {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<AccountType> type = const Value.absent(),
            Value<double> currentBalance = const Value.absent(),
            Value<String> icon = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<String?> operator = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              AccountsCompanion(
            id: id,
            name: name,
            type: type,
            currentBalance: currentBalance,
            icon: icon,
            color: color,
            operator: operator,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required AccountType type,
            Value<double> currentBalance = const Value.absent(),
            required String icon,
            required String color,
            Value<String?> operator = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              AccountsCompanion.insert(
            id: id,
            name: name,
            type: type,
            currentBalance: currentBalance,
            icon: icon,
            color: color,
            operator: operator,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$AccountsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({pendingTransactionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (pendingTransactionsRefs) db.pendingTransactions
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (pendingTransactionsRefs)
                    await $_getPrefetchedData<Account, $AccountsTable,
                            PendingTransaction>(
                        currentTable: table,
                        referencedTable: $$AccountsTableReferences
                            ._pendingTransactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AccountsTableReferences(db, table, p0)
                                .pendingTransactionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.suggestedAccountId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AccountsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, $$AccountsTableReferences),
    Account,
    PrefetchHooks Function({bool pendingTransactionsRefs})>;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  required String name,
  required String icon,
  required String color,
  required CategoryType type,
  Value<bool> isDefault,
  required DateTime createdAt,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> icon,
  Value<String> color,
  Value<CategoryType> type,
  Value<bool> isDefault,
  Value<DateTime> createdAt,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
      _transactionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.transactions,
              aliasName: $_aliasNameGenerator(
                  db.categories.id, db.transactions.categoryId));

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<CategoryType, CategoryType, int> get type =>
      $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> transactionsRefs(
      Expression<bool> Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
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

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CategoryType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> transactionsRefs<T extends Object>(
      Expression<T> Function($$TransactionsTableAnnotationComposer a) f) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, $$CategoriesTableReferences),
    Category,
    PrefetchHooks Function({bool transactionsRefs})> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> icon = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<CategoryType> type = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
            icon: icon,
            color: color,
            type: type,
            isDefault: isDefault,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String icon,
            required String color,
            required CategoryType type,
            Value<bool> isDefault = const Value.absent(),
            required DateTime createdAt,
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
            icon: icon,
            color: color,
            type: type,
            isDefault: isDefault,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({transactionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (transactionsRefs) db.transactions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionsRefs)
                    await $_getPrefetchedData<Category, $CategoriesTable,
                            Transaction>(
                        currentTable: table,
                        referencedTable: $$CategoriesTableReferences
                            ._transactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .transactionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, $$CategoriesTableReferences),
    Category,
    PrefetchHooks Function({bool transactionsRefs})>;
typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  required double amount,
  required TransactionType type,
  required DateTime date,
  Value<int?> categoryId,
  required int accountId,
  Value<int?> toAccountId,
  Value<double?> feeAmount,
  Value<bool> isException,
  Value<int?> scopeDuration,
  Value<String?> scopeType,
  Value<String?> description,
  Value<String?> source,
  required DateTime createdAt,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  Value<double> amount,
  Value<TransactionType> type,
  Value<DateTime> date,
  Value<int?> categoryId,
  Value<int> accountId,
  Value<int?> toAccountId,
  Value<double?> feeAmount,
  Value<bool> isException,
  Value<int?> scopeDuration,
  Value<String?> scopeType,
  Value<String?> description,
  Value<String?> source,
  Value<DateTime> createdAt,
});

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
          $_aliasNameGenerator(db.transactions.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias(
          $_aliasNameGenerator(db.transactions.accountId, db.accounts.id));

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<int>('account_id')!;

    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AccountsTable _toAccountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias(
          $_aliasNameGenerator(db.transactions.toAccountId, db.accounts.id));

  $$AccountsTableProcessedTableManager? get toAccountId {
    final $_column = $_itemColumn<int>('to_account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<TransactionType, TransactionType, int>
      get type => $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get feeAmount => $composableBuilder(
      column: $table.feeAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isException => $composableBuilder(
      column: $table.isException, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get scopeDuration => $composableBuilder(
      column: $table.scopeDuration, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scopeType => $composableBuilder(
      column: $table.scopeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableFilterComposer get toAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get feeAmount => $composableBuilder(
      column: $table.feeAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isException => $composableBuilder(
      column: $table.isException, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get scopeDuration => $composableBuilder(
      column: $table.scopeDuration,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scopeType => $composableBuilder(
      column: $table.scopeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableOrderingComposer get toAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransactionType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get feeAmount =>
      $composableBuilder(column: $table.feeAmount, builder: (column) => column);

  GeneratedColumn<bool> get isException => $composableBuilder(
      column: $table.isException, builder: (column) => column);

  GeneratedColumn<int> get scopeDuration => $composableBuilder(
      column: $table.scopeDuration, builder: (column) => column);

  GeneratedColumn<String> get scopeType =>
      $composableBuilder(column: $table.scopeType, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableAnnotationComposer get toAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (Transaction, $$TransactionsTableReferences),
    Transaction,
    PrefetchHooks Function(
        {bool categoryId, bool accountId, bool toAccountId})> {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<TransactionType> type = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<int?> categoryId = const Value.absent(),
            Value<int> accountId = const Value.absent(),
            Value<int?> toAccountId = const Value.absent(),
            Value<double?> feeAmount = const Value.absent(),
            Value<bool> isException = const Value.absent(),
            Value<int?> scopeDuration = const Value.absent(),
            Value<String?> scopeType = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> source = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              TransactionsCompanion(
            id: id,
            amount: amount,
            type: type,
            date: date,
            categoryId: categoryId,
            accountId: accountId,
            toAccountId: toAccountId,
            feeAmount: feeAmount,
            isException: isException,
            scopeDuration: scopeDuration,
            scopeType: scopeType,
            description: description,
            source: source,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required double amount,
            required TransactionType type,
            required DateTime date,
            Value<int?> categoryId = const Value.absent(),
            required int accountId,
            Value<int?> toAccountId = const Value.absent(),
            Value<double?> feeAmount = const Value.absent(),
            Value<bool> isException = const Value.absent(),
            Value<int?> scopeDuration = const Value.absent(),
            Value<String?> scopeType = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> source = const Value.absent(),
            required DateTime createdAt,
          }) =>
              TransactionsCompanion.insert(
            id: id,
            amount: amount,
            type: type,
            date: date,
            categoryId: categoryId,
            accountId: accountId,
            toAccountId: toAccountId,
            feeAmount: feeAmount,
            isException: isException,
            scopeDuration: scopeDuration,
            scopeType: scopeType,
            description: description,
            source: source,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TransactionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {categoryId = false, accountId = false, toAccountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$TransactionsTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$TransactionsTableReferences._categoryIdTable(db).id,
                  ) as T;
                }
                if (accountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.accountId,
                    referencedTable:
                        $$TransactionsTableReferences._accountIdTable(db),
                    referencedColumn:
                        $$TransactionsTableReferences._accountIdTable(db).id,
                  ) as T;
                }
                if (toAccountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.toAccountId,
                    referencedTable:
                        $$TransactionsTableReferences._toAccountIdTable(db),
                    referencedColumn:
                        $$TransactionsTableReferences._toAccountIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (Transaction, $$TransactionsTableReferences),
    Transaction,
    PrefetchHooks Function(
        {bool categoryId, bool accountId, bool toAccountId})>;
typedef $$RecurringChargesTableCreateCompanionBuilder
    = RecurringChargesCompanion Function({
  Value<int> id,
  required String name,
  required ChargeType type,
  required double amount,
  required DateTime dueDate,
  required ChargeCycle cycle,
  Value<bool> isPaid,
  Value<bool> isActive,
  required DateTime createdAt,
});
typedef $$RecurringChargesTableUpdateCompanionBuilder
    = RecurringChargesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<ChargeType> type,
  Value<double> amount,
  Value<DateTime> dueDate,
  Value<ChargeCycle> cycle,
  Value<bool> isPaid,
  Value<bool> isActive,
  Value<DateTime> createdAt,
});

class $$RecurringChargesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringChargesTable> {
  $$RecurringChargesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ChargeType, ChargeType, int> get type =>
      $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ChargeCycle, ChargeCycle, int> get cycle =>
      $composableBuilder(
          column: $table.cycle,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get isPaid => $composableBuilder(
      column: $table.isPaid, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$RecurringChargesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringChargesTable> {
  $$RecurringChargesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cycle => $composableBuilder(
      column: $table.cycle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPaid => $composableBuilder(
      column: $table.isPaid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$RecurringChargesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringChargesTable> {
  $$RecurringChargesTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<ChargeType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ChargeCycle, int> get cycle =>
      $composableBuilder(column: $table.cycle, builder: (column) => column);

  GeneratedColumn<bool> get isPaid =>
      $composableBuilder(column: $table.isPaid, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RecurringChargesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecurringChargesTable,
    RecurringCharge,
    $$RecurringChargesTableFilterComposer,
    $$RecurringChargesTableOrderingComposer,
    $$RecurringChargesTableAnnotationComposer,
    $$RecurringChargesTableCreateCompanionBuilder,
    $$RecurringChargesTableUpdateCompanionBuilder,
    (
      RecurringCharge,
      BaseReferences<_$AppDatabase, $RecurringChargesTable, RecurringCharge>
    ),
    RecurringCharge,
    PrefetchHooks Function()> {
  $$RecurringChargesTableTableManager(
      _$AppDatabase db, $RecurringChargesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringChargesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringChargesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringChargesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<ChargeType> type = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<DateTime> dueDate = const Value.absent(),
            Value<ChargeCycle> cycle = const Value.absent(),
            Value<bool> isPaid = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              RecurringChargesCompanion(
            id: id,
            name: name,
            type: type,
            amount: amount,
            dueDate: dueDate,
            cycle: cycle,
            isPaid: isPaid,
            isActive: isActive,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required ChargeType type,
            required double amount,
            required DateTime dueDate,
            required ChargeCycle cycle,
            Value<bool> isPaid = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required DateTime createdAt,
          }) =>
              RecurringChargesCompanion.insert(
            id: id,
            name: name,
            type: type,
            amount: amount,
            dueDate: dueDate,
            cycle: cycle,
            isPaid: isPaid,
            isActive: isActive,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RecurringChargesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecurringChargesTable,
    RecurringCharge,
    $$RecurringChargesTableFilterComposer,
    $$RecurringChargesTableOrderingComposer,
    $$RecurringChargesTableAnnotationComposer,
    $$RecurringChargesTableCreateCompanionBuilder,
    $$RecurringChargesTableUpdateCompanionBuilder,
    (
      RecurringCharge,
      BaseReferences<_$AppDatabase, $RecurringChargesTable, RecurringCharge>
    ),
    RecurringCharge,
    PrefetchHooks Function()>;
typedef $$PendingTransactionsTableCreateCompanionBuilder
    = PendingTransactionsCompanion Function({
  Value<int> id,
  required double amount,
  required String operator,
  Value<MomoTransactionType> momoType,
  Value<double> fee,
  Value<double?> balanceAfter,
  Value<String?> counterpart,
  Value<String?> counterpartPhone,
  Value<String?> momoRef,
  Value<DateTime?> transactionDate,
  required String rawSms,
  required DateTime smsDate,
  Value<String?> transactionId,
  Value<bool> isProcessed,
  Value<bool> countsInBudget,
  Value<int?> suggestedAccountId,
  required DateTime createdAt,
});
typedef $$PendingTransactionsTableUpdateCompanionBuilder
    = PendingTransactionsCompanion Function({
  Value<int> id,
  Value<double> amount,
  Value<String> operator,
  Value<MomoTransactionType> momoType,
  Value<double> fee,
  Value<double?> balanceAfter,
  Value<String?> counterpart,
  Value<String?> counterpartPhone,
  Value<String?> momoRef,
  Value<DateTime?> transactionDate,
  Value<String> rawSms,
  Value<DateTime> smsDate,
  Value<String?> transactionId,
  Value<bool> isProcessed,
  Value<bool> countsInBudget,
  Value<int?> suggestedAccountId,
  Value<DateTime> createdAt,
});

final class $$PendingTransactionsTableReferences extends BaseReferences<
    _$AppDatabase, $PendingTransactionsTable, PendingTransaction> {
  $$PendingTransactionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _suggestedAccountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias($_aliasNameGenerator(
          db.pendingTransactions.suggestedAccountId, db.accounts.id));

  $$AccountsTableProcessedTableManager? get suggestedAccountId {
    final $_column = $_itemColumn<int>('suggested_account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_suggestedAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PendingTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingTransactionsTable> {
  $$PendingTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operator => $composableBuilder(
      column: $table.operator, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<MomoTransactionType, MomoTransactionType, int>
      get momoType => $composableBuilder(
          column: $table.momoType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get fee => $composableBuilder(
      column: $table.fee, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get balanceAfter => $composableBuilder(
      column: $table.balanceAfter, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get counterpart => $composableBuilder(
      column: $table.counterpart, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get counterpartPhone => $composableBuilder(
      column: $table.counterpartPhone,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get momoRef => $composableBuilder(
      column: $table.momoRef, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get transactionDate => $composableBuilder(
      column: $table.transactionDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawSms => $composableBuilder(
      column: $table.rawSms, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get smsDate => $composableBuilder(
      column: $table.smsDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionId => $composableBuilder(
      column: $table.transactionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isProcessed => $composableBuilder(
      column: $table.isProcessed, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get countsInBudget => $composableBuilder(
      column: $table.countsInBudget,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$AccountsTableFilterComposer get suggestedAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.suggestedAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PendingTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingTransactionsTable> {
  $$PendingTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operator => $composableBuilder(
      column: $table.operator, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get momoType => $composableBuilder(
      column: $table.momoType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fee => $composableBuilder(
      column: $table.fee, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get balanceAfter => $composableBuilder(
      column: $table.balanceAfter,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get counterpart => $composableBuilder(
      column: $table.counterpart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get counterpartPhone => $composableBuilder(
      column: $table.counterpartPhone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get momoRef => $composableBuilder(
      column: $table.momoRef, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get transactionDate => $composableBuilder(
      column: $table.transactionDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawSms => $composableBuilder(
      column: $table.rawSms, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get smsDate => $composableBuilder(
      column: $table.smsDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionId => $composableBuilder(
      column: $table.transactionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isProcessed => $composableBuilder(
      column: $table.isProcessed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get countsInBudget => $composableBuilder(
      column: $table.countsInBudget,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$AccountsTableOrderingComposer get suggestedAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.suggestedAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PendingTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingTransactionsTable> {
  $$PendingTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get operator =>
      $composableBuilder(column: $table.operator, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MomoTransactionType, int> get momoType =>
      $composableBuilder(column: $table.momoType, builder: (column) => column);

  GeneratedColumn<double> get fee =>
      $composableBuilder(column: $table.fee, builder: (column) => column);

  GeneratedColumn<double> get balanceAfter => $composableBuilder(
      column: $table.balanceAfter, builder: (column) => column);

  GeneratedColumn<String> get counterpart => $composableBuilder(
      column: $table.counterpart, builder: (column) => column);

  GeneratedColumn<String> get counterpartPhone => $composableBuilder(
      column: $table.counterpartPhone, builder: (column) => column);

  GeneratedColumn<String> get momoRef =>
      $composableBuilder(column: $table.momoRef, builder: (column) => column);

  GeneratedColumn<DateTime> get transactionDate => $composableBuilder(
      column: $table.transactionDate, builder: (column) => column);

  GeneratedColumn<String> get rawSms =>
      $composableBuilder(column: $table.rawSms, builder: (column) => column);

  GeneratedColumn<DateTime> get smsDate =>
      $composableBuilder(column: $table.smsDate, builder: (column) => column);

  GeneratedColumn<String> get transactionId => $composableBuilder(
      column: $table.transactionId, builder: (column) => column);

  GeneratedColumn<bool> get isProcessed => $composableBuilder(
      column: $table.isProcessed, builder: (column) => column);

  GeneratedColumn<bool> get countsInBudget => $composableBuilder(
      column: $table.countsInBudget, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get suggestedAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.suggestedAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PendingTransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PendingTransactionsTable,
    PendingTransaction,
    $$PendingTransactionsTableFilterComposer,
    $$PendingTransactionsTableOrderingComposer,
    $$PendingTransactionsTableAnnotationComposer,
    $$PendingTransactionsTableCreateCompanionBuilder,
    $$PendingTransactionsTableUpdateCompanionBuilder,
    (PendingTransaction, $$PendingTransactionsTableReferences),
    PendingTransaction,
    PrefetchHooks Function({bool suggestedAccountId})> {
  $$PendingTransactionsTableTableManager(
      _$AppDatabase db, $PendingTransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingTransactionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingTransactionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> operator = const Value.absent(),
            Value<MomoTransactionType> momoType = const Value.absent(),
            Value<double> fee = const Value.absent(),
            Value<double?> balanceAfter = const Value.absent(),
            Value<String?> counterpart = const Value.absent(),
            Value<String?> counterpartPhone = const Value.absent(),
            Value<String?> momoRef = const Value.absent(),
            Value<DateTime?> transactionDate = const Value.absent(),
            Value<String> rawSms = const Value.absent(),
            Value<DateTime> smsDate = const Value.absent(),
            Value<String?> transactionId = const Value.absent(),
            Value<bool> isProcessed = const Value.absent(),
            Value<bool> countsInBudget = const Value.absent(),
            Value<int?> suggestedAccountId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PendingTransactionsCompanion(
            id: id,
            amount: amount,
            operator: operator,
            momoType: momoType,
            fee: fee,
            balanceAfter: balanceAfter,
            counterpart: counterpart,
            counterpartPhone: counterpartPhone,
            momoRef: momoRef,
            transactionDate: transactionDate,
            rawSms: rawSms,
            smsDate: smsDate,
            transactionId: transactionId,
            isProcessed: isProcessed,
            countsInBudget: countsInBudget,
            suggestedAccountId: suggestedAccountId,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required double amount,
            required String operator,
            Value<MomoTransactionType> momoType = const Value.absent(),
            Value<double> fee = const Value.absent(),
            Value<double?> balanceAfter = const Value.absent(),
            Value<String?> counterpart = const Value.absent(),
            Value<String?> counterpartPhone = const Value.absent(),
            Value<String?> momoRef = const Value.absent(),
            Value<DateTime?> transactionDate = const Value.absent(),
            required String rawSms,
            required DateTime smsDate,
            Value<String?> transactionId = const Value.absent(),
            Value<bool> isProcessed = const Value.absent(),
            Value<bool> countsInBudget = const Value.absent(),
            Value<int?> suggestedAccountId = const Value.absent(),
            required DateTime createdAt,
          }) =>
              PendingTransactionsCompanion.insert(
            id: id,
            amount: amount,
            operator: operator,
            momoType: momoType,
            fee: fee,
            balanceAfter: balanceAfter,
            counterpart: counterpart,
            counterpartPhone: counterpartPhone,
            momoRef: momoRef,
            transactionDate: transactionDate,
            rawSms: rawSms,
            smsDate: smsDate,
            transactionId: transactionId,
            isProcessed: isProcessed,
            countsInBudget: countsInBudget,
            suggestedAccountId: suggestedAccountId,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PendingTransactionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({suggestedAccountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (suggestedAccountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.suggestedAccountId,
                    referencedTable: $$PendingTransactionsTableReferences
                        ._suggestedAccountIdTable(db),
                    referencedColumn: $$PendingTransactionsTableReferences
                        ._suggestedAccountIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PendingTransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PendingTransactionsTable,
    PendingTransaction,
    $$PendingTransactionsTableFilterComposer,
    $$PendingTransactionsTableOrderingComposer,
    $$PendingTransactionsTableAnnotationComposer,
    $$PendingTransactionsTableCreateCompanionBuilder,
    $$PendingTransactionsTableUpdateCompanionBuilder,
    (PendingTransaction, $$PendingTransactionsTableReferences),
    PendingTransaction,
    PrefetchHooks Function({bool suggestedAccountId})>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  required String userName,
  Value<String> currency,
  required FinancialCycle financialCycle,
  required TransportMode transportMode,
  Value<double?> dailyTransportCost,
  Value<int?> transportDaysPerWeek,
  Value<double?> fixedTransportAmount,
  Value<bool> biometricEnabled,
  Value<bool> pinEnabled,
  Value<bool> discreteModeEnabled,
  Value<bool> smsParsingEnabled,
  Value<double> savingsGoal,
  Value<bool> onboardingCompleted,
  Value<String?> borderColor,
  Value<ThemeModePreference> themeMode,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<String> userName,
  Value<String> currency,
  Value<FinancialCycle> financialCycle,
  Value<TransportMode> transportMode,
  Value<double?> dailyTransportCost,
  Value<int?> transportDaysPerWeek,
  Value<double?> fixedTransportAmount,
  Value<bool> biometricEnabled,
  Value<bool> pinEnabled,
  Value<bool> discreteModeEnabled,
  Value<bool> smsParsingEnabled,
  Value<double> savingsGoal,
  Value<bool> onboardingCompleted,
  Value<String?> borderColor,
  Value<ThemeModePreference> themeMode,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userName => $composableBuilder(
      column: $table.userName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<FinancialCycle, FinancialCycle, int>
      get financialCycle => $composableBuilder(
          column: $table.financialCycle,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<TransportMode, TransportMode, int>
      get transportMode => $composableBuilder(
          column: $table.transportMode,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get dailyTransportCost => $composableBuilder(
      column: $table.dailyTransportCost,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get transportDaysPerWeek => $composableBuilder(
      column: $table.transportDaysPerWeek,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fixedTransportAmount => $composableBuilder(
      column: $table.fixedTransportAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get biometricEnabled => $composableBuilder(
      column: $table.biometricEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pinEnabled => $composableBuilder(
      column: $table.pinEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get discreteModeEnabled => $composableBuilder(
      column: $table.discreteModeEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get smsParsingEnabled => $composableBuilder(
      column: $table.smsParsingEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get savingsGoal => $composableBuilder(
      column: $table.savingsGoal, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get onboardingCompleted => $composableBuilder(
      column: $table.onboardingCompleted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get borderColor => $composableBuilder(
      column: $table.borderColor, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ThemeModePreference, ThemeModePreference, int>
      get themeMode => $composableBuilder(
          column: $table.themeMode,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userName => $composableBuilder(
      column: $table.userName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get financialCycle => $composableBuilder(
      column: $table.financialCycle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get transportMode => $composableBuilder(
      column: $table.transportMode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get dailyTransportCost => $composableBuilder(
      column: $table.dailyTransportCost,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get transportDaysPerWeek => $composableBuilder(
      column: $table.transportDaysPerWeek,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fixedTransportAmount => $composableBuilder(
      column: $table.fixedTransportAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get biometricEnabled => $composableBuilder(
      column: $table.biometricEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pinEnabled => $composableBuilder(
      column: $table.pinEnabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get discreteModeEnabled => $composableBuilder(
      column: $table.discreteModeEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get smsParsingEnabled => $composableBuilder(
      column: $table.smsParsingEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get savingsGoal => $composableBuilder(
      column: $table.savingsGoal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get onboardingCompleted => $composableBuilder(
      column: $table.onboardingCompleted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get borderColor => $composableBuilder(
      column: $table.borderColor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get themeMode => $composableBuilder(
      column: $table.themeMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userName =>
      $composableBuilder(column: $table.userName, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FinancialCycle, int> get financialCycle =>
      $composableBuilder(
          column: $table.financialCycle, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransportMode, int> get transportMode =>
      $composableBuilder(
          column: $table.transportMode, builder: (column) => column);

  GeneratedColumn<double> get dailyTransportCost => $composableBuilder(
      column: $table.dailyTransportCost, builder: (column) => column);

  GeneratedColumn<int> get transportDaysPerWeek => $composableBuilder(
      column: $table.transportDaysPerWeek, builder: (column) => column);

  GeneratedColumn<double> get fixedTransportAmount => $composableBuilder(
      column: $table.fixedTransportAmount, builder: (column) => column);

  GeneratedColumn<bool> get biometricEnabled => $composableBuilder(
      column: $table.biometricEnabled, builder: (column) => column);

  GeneratedColumn<bool> get pinEnabled => $composableBuilder(
      column: $table.pinEnabled, builder: (column) => column);

  GeneratedColumn<bool> get discreteModeEnabled => $composableBuilder(
      column: $table.discreteModeEnabled, builder: (column) => column);

  GeneratedColumn<bool> get smsParsingEnabled => $composableBuilder(
      column: $table.smsParsingEnabled, builder: (column) => column);

  GeneratedColumn<double> get savingsGoal => $composableBuilder(
      column: $table.savingsGoal, builder: (column) => column);

  GeneratedColumn<bool> get onboardingCompleted => $composableBuilder(
      column: $table.onboardingCompleted, builder: (column) => column);

  GeneratedColumn<String> get borderColor => $composableBuilder(
      column: $table.borderColor, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ThemeModePreference, int> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    UserSettings,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (UserSettings, BaseReferences<_$AppDatabase, $SettingsTable, UserSettings>),
    UserSettings,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> userName = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<FinancialCycle> financialCycle = const Value.absent(),
            Value<TransportMode> transportMode = const Value.absent(),
            Value<double?> dailyTransportCost = const Value.absent(),
            Value<int?> transportDaysPerWeek = const Value.absent(),
            Value<double?> fixedTransportAmount = const Value.absent(),
            Value<bool> biometricEnabled = const Value.absent(),
            Value<bool> pinEnabled = const Value.absent(),
            Value<bool> discreteModeEnabled = const Value.absent(),
            Value<bool> smsParsingEnabled = const Value.absent(),
            Value<double> savingsGoal = const Value.absent(),
            Value<bool> onboardingCompleted = const Value.absent(),
            Value<String?> borderColor = const Value.absent(),
            Value<ThemeModePreference> themeMode = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SettingsCompanion(
            id: id,
            userName: userName,
            currency: currency,
            financialCycle: financialCycle,
            transportMode: transportMode,
            dailyTransportCost: dailyTransportCost,
            transportDaysPerWeek: transportDaysPerWeek,
            fixedTransportAmount: fixedTransportAmount,
            biometricEnabled: biometricEnabled,
            pinEnabled: pinEnabled,
            discreteModeEnabled: discreteModeEnabled,
            smsParsingEnabled: smsParsingEnabled,
            savingsGoal: savingsGoal,
            onboardingCompleted: onboardingCompleted,
            borderColor: borderColor,
            themeMode: themeMode,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String userName,
            Value<String> currency = const Value.absent(),
            required FinancialCycle financialCycle,
            required TransportMode transportMode,
            Value<double?> dailyTransportCost = const Value.absent(),
            Value<int?> transportDaysPerWeek = const Value.absent(),
            Value<double?> fixedTransportAmount = const Value.absent(),
            Value<bool> biometricEnabled = const Value.absent(),
            Value<bool> pinEnabled = const Value.absent(),
            Value<bool> discreteModeEnabled = const Value.absent(),
            Value<bool> smsParsingEnabled = const Value.absent(),
            Value<double> savingsGoal = const Value.absent(),
            Value<bool> onboardingCompleted = const Value.absent(),
            Value<String?> borderColor = const Value.absent(),
            Value<ThemeModePreference> themeMode = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              SettingsCompanion.insert(
            id: id,
            userName: userName,
            currency: currency,
            financialCycle: financialCycle,
            transportMode: transportMode,
            dailyTransportCost: dailyTransportCost,
            transportDaysPerWeek: transportDaysPerWeek,
            fixedTransportAmount: fixedTransportAmount,
            biometricEnabled: biometricEnabled,
            pinEnabled: pinEnabled,
            discreteModeEnabled: discreteModeEnabled,
            smsParsingEnabled: smsParsingEnabled,
            savingsGoal: savingsGoal,
            onboardingCompleted: onboardingCompleted,
            borderColor: borderColor,
            themeMode: themeMode,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    UserSettings,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (UserSettings, BaseReferences<_$AppDatabase, $SettingsTable, UserSettings>),
    UserSettings,
    PrefetchHooks Function()>;
typedef $$IncomePatternsTableCreateCompanionBuilder = IncomePatternsCompanion
    Function({
  Value<int> id,
  required double estimatedWeeklyIncome,
  required double minimumObserved,
  required double maximumObserved,
  required double averageObserved,
  required double variance,
  required bool isRegular,
  required int transactionCount,
  Value<int> analysisWindowDays,
  required String frequency,
  Value<DateTime?> nextPredictedDate,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$IncomePatternsTableUpdateCompanionBuilder = IncomePatternsCompanion
    Function({
  Value<int> id,
  Value<double> estimatedWeeklyIncome,
  Value<double> minimumObserved,
  Value<double> maximumObserved,
  Value<double> averageObserved,
  Value<double> variance,
  Value<bool> isRegular,
  Value<int> transactionCount,
  Value<int> analysisWindowDays,
  Value<String> frequency,
  Value<DateTime?> nextPredictedDate,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$IncomePatternsTableFilterComposer
    extends Composer<_$AppDatabase, $IncomePatternsTable> {
  $$IncomePatternsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get estimatedWeeklyIncome => $composableBuilder(
      column: $table.estimatedWeeklyIncome,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get minimumObserved => $composableBuilder(
      column: $table.minimumObserved,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get maximumObserved => $composableBuilder(
      column: $table.maximumObserved,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get averageObserved => $composableBuilder(
      column: $table.averageObserved,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get variance => $composableBuilder(
      column: $table.variance, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRegular => $composableBuilder(
      column: $table.isRegular, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get transactionCount => $composableBuilder(
      column: $table.transactionCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get analysisWindowDays => $composableBuilder(
      column: $table.analysisWindowDays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextPredictedDate => $composableBuilder(
      column: $table.nextPredictedDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$IncomePatternsTableOrderingComposer
    extends Composer<_$AppDatabase, $IncomePatternsTable> {
  $$IncomePatternsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get estimatedWeeklyIncome => $composableBuilder(
      column: $table.estimatedWeeklyIncome,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get minimumObserved => $composableBuilder(
      column: $table.minimumObserved,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get maximumObserved => $composableBuilder(
      column: $table.maximumObserved,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get averageObserved => $composableBuilder(
      column: $table.averageObserved,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get variance => $composableBuilder(
      column: $table.variance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRegular => $composableBuilder(
      column: $table.isRegular, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get transactionCount => $composableBuilder(
      column: $table.transactionCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get analysisWindowDays => $composableBuilder(
      column: $table.analysisWindowDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextPredictedDate => $composableBuilder(
      column: $table.nextPredictedDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$IncomePatternsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IncomePatternsTable> {
  $$IncomePatternsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get estimatedWeeklyIncome => $composableBuilder(
      column: $table.estimatedWeeklyIncome, builder: (column) => column);

  GeneratedColumn<double> get minimumObserved => $composableBuilder(
      column: $table.minimumObserved, builder: (column) => column);

  GeneratedColumn<double> get maximumObserved => $composableBuilder(
      column: $table.maximumObserved, builder: (column) => column);

  GeneratedColumn<double> get averageObserved => $composableBuilder(
      column: $table.averageObserved, builder: (column) => column);

  GeneratedColumn<double> get variance =>
      $composableBuilder(column: $table.variance, builder: (column) => column);

  GeneratedColumn<bool> get isRegular =>
      $composableBuilder(column: $table.isRegular, builder: (column) => column);

  GeneratedColumn<int> get transactionCount => $composableBuilder(
      column: $table.transactionCount, builder: (column) => column);

  GeneratedColumn<int> get analysisWindowDays => $composableBuilder(
      column: $table.analysisWindowDays, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<DateTime> get nextPredictedDate => $composableBuilder(
      column: $table.nextPredictedDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$IncomePatternsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $IncomePatternsTable,
    IncomePattern,
    $$IncomePatternsTableFilterComposer,
    $$IncomePatternsTableOrderingComposer,
    $$IncomePatternsTableAnnotationComposer,
    $$IncomePatternsTableCreateCompanionBuilder,
    $$IncomePatternsTableUpdateCompanionBuilder,
    (
      IncomePattern,
      BaseReferences<_$AppDatabase, $IncomePatternsTable, IncomePattern>
    ),
    IncomePattern,
    PrefetchHooks Function()> {
  $$IncomePatternsTableTableManager(
      _$AppDatabase db, $IncomePatternsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncomePatternsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IncomePatternsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IncomePatternsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<double> estimatedWeeklyIncome = const Value.absent(),
            Value<double> minimumObserved = const Value.absent(),
            Value<double> maximumObserved = const Value.absent(),
            Value<double> averageObserved = const Value.absent(),
            Value<double> variance = const Value.absent(),
            Value<bool> isRegular = const Value.absent(),
            Value<int> transactionCount = const Value.absent(),
            Value<int> analysisWindowDays = const Value.absent(),
            Value<String> frequency = const Value.absent(),
            Value<DateTime?> nextPredictedDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              IncomePatternsCompanion(
            id: id,
            estimatedWeeklyIncome: estimatedWeeklyIncome,
            minimumObserved: minimumObserved,
            maximumObserved: maximumObserved,
            averageObserved: averageObserved,
            variance: variance,
            isRegular: isRegular,
            transactionCount: transactionCount,
            analysisWindowDays: analysisWindowDays,
            frequency: frequency,
            nextPredictedDate: nextPredictedDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required double estimatedWeeklyIncome,
            required double minimumObserved,
            required double maximumObserved,
            required double averageObserved,
            required double variance,
            required bool isRegular,
            required int transactionCount,
            Value<int> analysisWindowDays = const Value.absent(),
            required String frequency,
            Value<DateTime?> nextPredictedDate = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              IncomePatternsCompanion.insert(
            id: id,
            estimatedWeeklyIncome: estimatedWeeklyIncome,
            minimumObserved: minimumObserved,
            maximumObserved: maximumObserved,
            averageObserved: averageObserved,
            variance: variance,
            isRegular: isRegular,
            transactionCount: transactionCount,
            analysisWindowDays: analysisWindowDays,
            frequency: frequency,
            nextPredictedDate: nextPredictedDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$IncomePatternsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $IncomePatternsTable,
    IncomePattern,
    $$IncomePatternsTableFilterComposer,
    $$IncomePatternsTableOrderingComposer,
    $$IncomePatternsTableAnnotationComposer,
    $$IncomePatternsTableCreateCompanionBuilder,
    $$IncomePatternsTableUpdateCompanionBuilder,
    (
      IncomePattern,
      BaseReferences<_$AppDatabase, $IncomePatternsTable, IncomePattern>
    ),
    IncomePattern,
    PrefetchHooks Function()>;
typedef $$InsightsTableCreateCompanionBuilder = InsightsCompanion Function({
  Value<int> id,
  required String type,
  required double totalAmount,
  required int transactionCount,
  required String categoryNames,
  required double percentageOfAvailable,
  Value<bool> isDismissed,
  required DateTime detectedAt,
  required DateTime expiresAt,
  required DateTime createdAt,
});
typedef $$InsightsTableUpdateCompanionBuilder = InsightsCompanion Function({
  Value<int> id,
  Value<String> type,
  Value<double> totalAmount,
  Value<int> transactionCount,
  Value<String> categoryNames,
  Value<double> percentageOfAvailable,
  Value<bool> isDismissed,
  Value<DateTime> detectedAt,
  Value<DateTime> expiresAt,
  Value<DateTime> createdAt,
});

class $$InsightsTableFilterComposer
    extends Composer<_$AppDatabase, $InsightsTable> {
  $$InsightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get transactionCount => $composableBuilder(
      column: $table.transactionCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryNames => $composableBuilder(
      column: $table.categoryNames, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get percentageOfAvailable => $composableBuilder(
      column: $table.percentageOfAvailable,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDismissed => $composableBuilder(
      column: $table.isDismissed, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get detectedAt => $composableBuilder(
      column: $table.detectedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$InsightsTableOrderingComposer
    extends Composer<_$AppDatabase, $InsightsTable> {
  $$InsightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get transactionCount => $composableBuilder(
      column: $table.transactionCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryNames => $composableBuilder(
      column: $table.categoryNames,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get percentageOfAvailable => $composableBuilder(
      column: $table.percentageOfAvailable,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDismissed => $composableBuilder(
      column: $table.isDismissed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get detectedAt => $composableBuilder(
      column: $table.detectedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$InsightsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InsightsTable> {
  $$InsightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => column);

  GeneratedColumn<int> get transactionCount => $composableBuilder(
      column: $table.transactionCount, builder: (column) => column);

  GeneratedColumn<String> get categoryNames => $composableBuilder(
      column: $table.categoryNames, builder: (column) => column);

  GeneratedColumn<double> get percentageOfAvailable => $composableBuilder(
      column: $table.percentageOfAvailable, builder: (column) => column);

  GeneratedColumn<bool> get isDismissed => $composableBuilder(
      column: $table.isDismissed, builder: (column) => column);

  GeneratedColumn<DateTime> get detectedAt => $composableBuilder(
      column: $table.detectedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$InsightsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InsightsTable,
    Insight,
    $$InsightsTableFilterComposer,
    $$InsightsTableOrderingComposer,
    $$InsightsTableAnnotationComposer,
    $$InsightsTableCreateCompanionBuilder,
    $$InsightsTableUpdateCompanionBuilder,
    (Insight, BaseReferences<_$AppDatabase, $InsightsTable, Insight>),
    Insight,
    PrefetchHooks Function()> {
  $$InsightsTableTableManager(_$AppDatabase db, $InsightsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InsightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InsightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InsightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<double> totalAmount = const Value.absent(),
            Value<int> transactionCount = const Value.absent(),
            Value<String> categoryNames = const Value.absent(),
            Value<double> percentageOfAvailable = const Value.absent(),
            Value<bool> isDismissed = const Value.absent(),
            Value<DateTime> detectedAt = const Value.absent(),
            Value<DateTime> expiresAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              InsightsCompanion(
            id: id,
            type: type,
            totalAmount: totalAmount,
            transactionCount: transactionCount,
            categoryNames: categoryNames,
            percentageOfAvailable: percentageOfAvailable,
            isDismissed: isDismissed,
            detectedAt: detectedAt,
            expiresAt: expiresAt,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String type,
            required double totalAmount,
            required int transactionCount,
            required String categoryNames,
            required double percentageOfAvailable,
            Value<bool> isDismissed = const Value.absent(),
            required DateTime detectedAt,
            required DateTime expiresAt,
            required DateTime createdAt,
          }) =>
              InsightsCompanion.insert(
            id: id,
            type: type,
            totalAmount: totalAmount,
            transactionCount: transactionCount,
            categoryNames: categoryNames,
            percentageOfAvailable: percentageOfAvailable,
            isDismissed: isDismissed,
            detectedAt: detectedAt,
            expiresAt: expiresAt,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InsightsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InsightsTable,
    Insight,
    $$InsightsTableFilterComposer,
    $$InsightsTableOrderingComposer,
    $$InsightsTableAnnotationComposer,
    $$InsightsTableCreateCompanionBuilder,
    $$InsightsTableUpdateCompanionBuilder,
    (Insight, BaseReferences<_$AppDatabase, $InsightsTable, Insight>),
    Insight,
    PrefetchHooks Function()>;
typedef $$BehavioralProfilesTableCreateCompanionBuilder
    = BehavioralProfilesCompanion Function({
  Value<int> id,
  required double spendingFrequency,
  required String hourlyPattern,
  required int overrunCount,
  required double averageOverrun,
  required String advisoryLevel,
  required DateTime lastUpdated,
  required DateTime createdAt,
});
typedef $$BehavioralProfilesTableUpdateCompanionBuilder
    = BehavioralProfilesCompanion Function({
  Value<int> id,
  Value<double> spendingFrequency,
  Value<String> hourlyPattern,
  Value<int> overrunCount,
  Value<double> averageOverrun,
  Value<String> advisoryLevel,
  Value<DateTime> lastUpdated,
  Value<DateTime> createdAt,
});

class $$BehavioralProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $BehavioralProfilesTable> {
  $$BehavioralProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get spendingFrequency => $composableBuilder(
      column: $table.spendingFrequency,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hourlyPattern => $composableBuilder(
      column: $table.hourlyPattern, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get overrunCount => $composableBuilder(
      column: $table.overrunCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get averageOverrun => $composableBuilder(
      column: $table.averageOverrun,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get advisoryLevel => $composableBuilder(
      column: $table.advisoryLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$BehavioralProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $BehavioralProfilesTable> {
  $$BehavioralProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get spendingFrequency => $composableBuilder(
      column: $table.spendingFrequency,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hourlyPattern => $composableBuilder(
      column: $table.hourlyPattern,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get overrunCount => $composableBuilder(
      column: $table.overrunCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get averageOverrun => $composableBuilder(
      column: $table.averageOverrun,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get advisoryLevel => $composableBuilder(
      column: $table.advisoryLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$BehavioralProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BehavioralProfilesTable> {
  $$BehavioralProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get spendingFrequency => $composableBuilder(
      column: $table.spendingFrequency, builder: (column) => column);

  GeneratedColumn<String> get hourlyPattern => $composableBuilder(
      column: $table.hourlyPattern, builder: (column) => column);

  GeneratedColumn<int> get overrunCount => $composableBuilder(
      column: $table.overrunCount, builder: (column) => column);

  GeneratedColumn<double> get averageOverrun => $composableBuilder(
      column: $table.averageOverrun, builder: (column) => column);

  GeneratedColumn<String> get advisoryLevel => $composableBuilder(
      column: $table.advisoryLevel, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BehavioralProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BehavioralProfilesTable,
    BehavioralProfile,
    $$BehavioralProfilesTableFilterComposer,
    $$BehavioralProfilesTableOrderingComposer,
    $$BehavioralProfilesTableAnnotationComposer,
    $$BehavioralProfilesTableCreateCompanionBuilder,
    $$BehavioralProfilesTableUpdateCompanionBuilder,
    (
      BehavioralProfile,
      BaseReferences<_$AppDatabase, $BehavioralProfilesTable, BehavioralProfile>
    ),
    BehavioralProfile,
    PrefetchHooks Function()> {
  $$BehavioralProfilesTableTableManager(
      _$AppDatabase db, $BehavioralProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BehavioralProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BehavioralProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BehavioralProfilesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<double> spendingFrequency = const Value.absent(),
            Value<String> hourlyPattern = const Value.absent(),
            Value<int> overrunCount = const Value.absent(),
            Value<double> averageOverrun = const Value.absent(),
            Value<String> advisoryLevel = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BehavioralProfilesCompanion(
            id: id,
            spendingFrequency: spendingFrequency,
            hourlyPattern: hourlyPattern,
            overrunCount: overrunCount,
            averageOverrun: averageOverrun,
            advisoryLevel: advisoryLevel,
            lastUpdated: lastUpdated,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required double spendingFrequency,
            required String hourlyPattern,
            required int overrunCount,
            required double averageOverrun,
            required String advisoryLevel,
            required DateTime lastUpdated,
            required DateTime createdAt,
          }) =>
              BehavioralProfilesCompanion.insert(
            id: id,
            spendingFrequency: spendingFrequency,
            hourlyPattern: hourlyPattern,
            overrunCount: overrunCount,
            averageOverrun: averageOverrun,
            advisoryLevel: advisoryLevel,
            lastUpdated: lastUpdated,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BehavioralProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BehavioralProfilesTable,
    BehavioralProfile,
    $$BehavioralProfilesTableFilterComposer,
    $$BehavioralProfilesTableOrderingComposer,
    $$BehavioralProfilesTableAnnotationComposer,
    $$BehavioralProfilesTableCreateCompanionBuilder,
    $$BehavioralProfilesTableUpdateCompanionBuilder,
    (
      BehavioralProfile,
      BaseReferences<_$AppDatabase, $BehavioralProfilesTable, BehavioralProfile>
    ),
    BehavioralProfile,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$RecurringChargesTableTableManager get recurringCharges =>
      $$RecurringChargesTableTableManager(_db, _db.recurringCharges);
  $$PendingTransactionsTableTableManager get pendingTransactions =>
      $$PendingTransactionsTableTableManager(_db, _db.pendingTransactions);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$IncomePatternsTableTableManager get incomePatterns =>
      $$IncomePatternsTableTableManager(_db, _db.incomePatterns);
  $$InsightsTableTableManager get insights =>
      $$InsightsTableTableManager(_db, _db.insights);
  $$BehavioralProfilesTableTableManager get behavioralProfiles =>
      $$BehavioralProfilesTableTableManager(_db, _db.behavioralProfiles);
}
