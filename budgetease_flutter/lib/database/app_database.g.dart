// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TransactionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<TransactionType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<TransactionType>($TransactionsTable.$convertertype);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WalletType, int> sourceWallet =
      GeneratedColumn<int>(
        'source_wallet',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<WalletType>($TransactionsTable.$convertersourceWallet);
  @override
  late final GeneratedColumnWithTypeConverter<WalletType, int>
  destinationWallet = GeneratedColumn<int>(
    'destination_wallet',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  ).withConverter<WalletType>($TransactionsTable.$converterdestinationWallet);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isShieldRelatedMeta = const VerificationMeta(
    'isShieldRelated',
  );
  @override
  late final GeneratedColumn<bool> isShieldRelated = GeneratedColumn<bool>(
    'is_shield_related',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_shield_related" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _incomeFrequencyMeta = const VerificationMeta(
    'incomeFrequency',
  );
  @override
  late final GeneratedColumn<String> incomeFrequency = GeneratedColumn<String>(
    'income_frequency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shadowSavingsMeta = const VerificationMeta(
    'shadowSavings',
  );
  @override
  late final GeneratedColumn<double> shadowSavings = GeneratedColumn<double>(
    'shadow_savings',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    date,
    amount,
    category,
    sourceWallet,
    destinationWallet,
    note,
    isShieldRelated,
    createdAt,
    incomeFrequency,
    shadowSavings,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('is_shield_related')) {
      context.handle(
        _isShieldRelatedMeta,
        isShieldRelated.isAcceptableOrUnknown(
          data['is_shield_related']!,
          _isShieldRelatedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('income_frequency')) {
      context.handle(
        _incomeFrequencyMeta,
        incomeFrequency.isAcceptableOrUnknown(
          data['income_frequency']!,
          _incomeFrequencyMeta,
        ),
      );
    }
    if (data.containsKey('shadow_savings')) {
      context.handle(
        _shadowSavingsMeta,
        shadowSavings.isAcceptableOrUnknown(
          data['shadow_savings']!,
          _shadowSavingsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: $TransactionsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      sourceWallet: $TransactionsTable.$convertersourceWallet.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}source_wallet'],
        )!,
      ),
      destinationWallet: $TransactionsTable.$converterdestinationWallet.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}destination_wallet'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      isShieldRelated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_shield_related'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      incomeFrequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}income_frequency'],
      ),
      shadowSavings: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}shadow_savings'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TransactionType, int, int> $convertertype =
      const EnumIndexConverter<TransactionType>(TransactionType.values);
  static JsonTypeConverter2<WalletType, int, int> $convertersourceWallet =
      const EnumIndexConverter<WalletType>(WalletType.values);
  static JsonTypeConverter2<WalletType, int, int> $converterdestinationWallet =
      const EnumIndexConverter<WalletType>(WalletType.values);
}

class TransactionData extends DataClass implements Insertable<TransactionData> {
  final int id;

  /// Type of transaction (expense, income, transfer)
  final TransactionType type;

  /// Date of the transaction
  final DateTime date;

  /// Amount in FCFA
  final double amount;

  /// Category (Alimentation, Transport, etc.)
  final String category;

  /// Source wallet
  final WalletType sourceWallet;

  /// Destination wallet (for transfers)
  final WalletType destinationWallet;

  /// Optional note
  final String? note;

  /// Is this related to shield items?
  final bool isShieldRelated;

  /// Creation timestamp
  final DateTime createdAt;

  /// Income frequency if applicable
  final String? incomeFrequency;

  /// Shadow savings amount (auto-saved)
  final double shadowSavings;
  const TransactionData({
    required this.id,
    required this.type,
    required this.date,
    required this.amount,
    required this.category,
    required this.sourceWallet,
    required this.destinationWallet,
    this.note,
    required this.isShieldRelated,
    required this.createdAt,
    this.incomeFrequency,
    required this.shadowSavings,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['type'] = Variable<int>(
        $TransactionsTable.$convertertype.toSql(type),
      );
    }
    map['date'] = Variable<DateTime>(date);
    map['amount'] = Variable<double>(amount);
    map['category'] = Variable<String>(category);
    {
      map['source_wallet'] = Variable<int>(
        $TransactionsTable.$convertersourceWallet.toSql(sourceWallet),
      );
    }
    {
      map['destination_wallet'] = Variable<int>(
        $TransactionsTable.$converterdestinationWallet.toSql(destinationWallet),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['is_shield_related'] = Variable<bool>(isShieldRelated);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || incomeFrequency != null) {
      map['income_frequency'] = Variable<String>(incomeFrequency);
    }
    map['shadow_savings'] = Variable<double>(shadowSavings);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      type: Value(type),
      date: Value(date),
      amount: Value(amount),
      category: Value(category),
      sourceWallet: Value(sourceWallet),
      destinationWallet: Value(destinationWallet),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      isShieldRelated: Value(isShieldRelated),
      createdAt: Value(createdAt),
      incomeFrequency: incomeFrequency == null && nullToAbsent
          ? const Value.absent()
          : Value(incomeFrequency),
      shadowSavings: Value(shadowSavings),
    );
  }

  factory TransactionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionData(
      id: serializer.fromJson<int>(json['id']),
      type: $TransactionsTable.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      date: serializer.fromJson<DateTime>(json['date']),
      amount: serializer.fromJson<double>(json['amount']),
      category: serializer.fromJson<String>(json['category']),
      sourceWallet: $TransactionsTable.$convertersourceWallet.fromJson(
        serializer.fromJson<int>(json['sourceWallet']),
      ),
      destinationWallet: $TransactionsTable.$converterdestinationWallet
          .fromJson(serializer.fromJson<int>(json['destinationWallet'])),
      note: serializer.fromJson<String?>(json['note']),
      isShieldRelated: serializer.fromJson<bool>(json['isShieldRelated']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      incomeFrequency: serializer.fromJson<String?>(json['incomeFrequency']),
      shadowSavings: serializer.fromJson<double>(json['shadowSavings']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<int>(
        $TransactionsTable.$convertertype.toJson(type),
      ),
      'date': serializer.toJson<DateTime>(date),
      'amount': serializer.toJson<double>(amount),
      'category': serializer.toJson<String>(category),
      'sourceWallet': serializer.toJson<int>(
        $TransactionsTable.$convertersourceWallet.toJson(sourceWallet),
      ),
      'destinationWallet': serializer.toJson<int>(
        $TransactionsTable.$converterdestinationWallet.toJson(
          destinationWallet,
        ),
      ),
      'note': serializer.toJson<String?>(note),
      'isShieldRelated': serializer.toJson<bool>(isShieldRelated),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'incomeFrequency': serializer.toJson<String?>(incomeFrequency),
      'shadowSavings': serializer.toJson<double>(shadowSavings),
    };
  }

  TransactionData copyWith({
    int? id,
    TransactionType? type,
    DateTime? date,
    double? amount,
    String? category,
    WalletType? sourceWallet,
    WalletType? destinationWallet,
    Value<String?> note = const Value.absent(),
    bool? isShieldRelated,
    DateTime? createdAt,
    Value<String?> incomeFrequency = const Value.absent(),
    double? shadowSavings,
  }) => TransactionData(
    id: id ?? this.id,
    type: type ?? this.type,
    date: date ?? this.date,
    amount: amount ?? this.amount,
    category: category ?? this.category,
    sourceWallet: sourceWallet ?? this.sourceWallet,
    destinationWallet: destinationWallet ?? this.destinationWallet,
    note: note.present ? note.value : this.note,
    isShieldRelated: isShieldRelated ?? this.isShieldRelated,
    createdAt: createdAt ?? this.createdAt,
    incomeFrequency: incomeFrequency.present
        ? incomeFrequency.value
        : this.incomeFrequency,
    shadowSavings: shadowSavings ?? this.shadowSavings,
  );
  TransactionData copyWithCompanion(TransactionsCompanion data) {
    return TransactionData(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      date: data.date.present ? data.date.value : this.date,
      amount: data.amount.present ? data.amount.value : this.amount,
      category: data.category.present ? data.category.value : this.category,
      sourceWallet: data.sourceWallet.present
          ? data.sourceWallet.value
          : this.sourceWallet,
      destinationWallet: data.destinationWallet.present
          ? data.destinationWallet.value
          : this.destinationWallet,
      note: data.note.present ? data.note.value : this.note,
      isShieldRelated: data.isShieldRelated.present
          ? data.isShieldRelated.value
          : this.isShieldRelated,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      incomeFrequency: data.incomeFrequency.present
          ? data.incomeFrequency.value
          : this.incomeFrequency,
      shadowSavings: data.shadowSavings.present
          ? data.shadowSavings.value
          : this.shadowSavings,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionData(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('sourceWallet: $sourceWallet, ')
          ..write('destinationWallet: $destinationWallet, ')
          ..write('note: $note, ')
          ..write('isShieldRelated: $isShieldRelated, ')
          ..write('createdAt: $createdAt, ')
          ..write('incomeFrequency: $incomeFrequency, ')
          ..write('shadowSavings: $shadowSavings')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    date,
    amount,
    category,
    sourceWallet,
    destinationWallet,
    note,
    isShieldRelated,
    createdAt,
    incomeFrequency,
    shadowSavings,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionData &&
          other.id == this.id &&
          other.type == this.type &&
          other.date == this.date &&
          other.amount == this.amount &&
          other.category == this.category &&
          other.sourceWallet == this.sourceWallet &&
          other.destinationWallet == this.destinationWallet &&
          other.note == this.note &&
          other.isShieldRelated == this.isShieldRelated &&
          other.createdAt == this.createdAt &&
          other.incomeFrequency == this.incomeFrequency &&
          other.shadowSavings == this.shadowSavings);
}

class TransactionsCompanion extends UpdateCompanion<TransactionData> {
  final Value<int> id;
  final Value<TransactionType> type;
  final Value<DateTime> date;
  final Value<double> amount;
  final Value<String> category;
  final Value<WalletType> sourceWallet;
  final Value<WalletType> destinationWallet;
  final Value<String?> note;
  final Value<bool> isShieldRelated;
  final Value<DateTime> createdAt;
  final Value<String?> incomeFrequency;
  final Value<double> shadowSavings;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.date = const Value.absent(),
    this.amount = const Value.absent(),
    this.category = const Value.absent(),
    this.sourceWallet = const Value.absent(),
    this.destinationWallet = const Value.absent(),
    this.note = const Value.absent(),
    this.isShieldRelated = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.incomeFrequency = const Value.absent(),
    this.shadowSavings = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required TransactionType type,
    required DateTime date,
    required double amount,
    required String category,
    required WalletType sourceWallet,
    this.destinationWallet = const Value.absent(),
    this.note = const Value.absent(),
    this.isShieldRelated = const Value.absent(),
    required DateTime createdAt,
    this.incomeFrequency = const Value.absent(),
    this.shadowSavings = const Value.absent(),
  }) : type = Value(type),
       date = Value(date),
       amount = Value(amount),
       category = Value(category),
       sourceWallet = Value(sourceWallet),
       createdAt = Value(createdAt);
  static Insertable<TransactionData> custom({
    Expression<int>? id,
    Expression<int>? type,
    Expression<DateTime>? date,
    Expression<double>? amount,
    Expression<String>? category,
    Expression<int>? sourceWallet,
    Expression<int>? destinationWallet,
    Expression<String>? note,
    Expression<bool>? isShieldRelated,
    Expression<DateTime>? createdAt,
    Expression<String>? incomeFrequency,
    Expression<double>? shadowSavings,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (date != null) 'date': date,
      if (amount != null) 'amount': amount,
      if (category != null) 'category': category,
      if (sourceWallet != null) 'source_wallet': sourceWallet,
      if (destinationWallet != null) 'destination_wallet': destinationWallet,
      if (note != null) 'note': note,
      if (isShieldRelated != null) 'is_shield_related': isShieldRelated,
      if (createdAt != null) 'created_at': createdAt,
      if (incomeFrequency != null) 'income_frequency': incomeFrequency,
      if (shadowSavings != null) 'shadow_savings': shadowSavings,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<TransactionType>? type,
    Value<DateTime>? date,
    Value<double>? amount,
    Value<String>? category,
    Value<WalletType>? sourceWallet,
    Value<WalletType>? destinationWallet,
    Value<String?>? note,
    Value<bool>? isShieldRelated,
    Value<DateTime>? createdAt,
    Value<String?>? incomeFrequency,
    Value<double>? shadowSavings,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      sourceWallet: sourceWallet ?? this.sourceWallet,
      destinationWallet: destinationWallet ?? this.destinationWallet,
      note: note ?? this.note,
      isShieldRelated: isShieldRelated ?? this.isShieldRelated,
      createdAt: createdAt ?? this.createdAt,
      incomeFrequency: incomeFrequency ?? this.incomeFrequency,
      shadowSavings: shadowSavings ?? this.shadowSavings,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(
        $TransactionsTable.$convertertype.toSql(type.value),
      );
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (sourceWallet.present) {
      map['source_wallet'] = Variable<int>(
        $TransactionsTable.$convertersourceWallet.toSql(sourceWallet.value),
      );
    }
    if (destinationWallet.present) {
      map['destination_wallet'] = Variable<int>(
        $TransactionsTable.$converterdestinationWallet.toSql(
          destinationWallet.value,
        ),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (isShieldRelated.present) {
      map['is_shield_related'] = Variable<bool>(isShieldRelated.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (incomeFrequency.present) {
      map['income_frequency'] = Variable<String>(incomeFrequency.value);
    }
    if (shadowSavings.present) {
      map['shadow_savings'] = Variable<double>(shadowSavings.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('sourceWallet: $sourceWallet, ')
          ..write('destinationWallet: $destinationWallet, ')
          ..write('note: $note, ')
          ..write('isShieldRelated: $isShieldRelated, ')
          ..write('createdAt: $createdAt, ')
          ..write('incomeFrequency: $incomeFrequency, ')
          ..write('shadowSavings: $shadowSavings')
          ..write(')'))
        .toString();
  }
}

class $WalletsTable extends Wallets with TableInfo<$WalletsTable, WalletData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletsTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WalletType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<WalletType>($WalletsTable.$convertertype);
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    type,
    balance,
    icon,
    color,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallets';
  @override
  VerificationContext validateIntegrity(
    Insertable<WalletData> instance, {
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
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
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
  WalletData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalletData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: $WalletsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WalletsTable createAlias(String alias) {
    return $WalletsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<WalletType, int, int> $convertertype =
      const EnumIndexConverter<WalletType>(WalletType.values);
}

class WalletData extends DataClass implements Insertable<WalletData> {
  final int id;

  /// Wallet display name (Cash, MTN MoMo, etc.)
  final String name;

  /// Wallet type enum
  final WalletType type;

  /// Current balance in FCFA
  final double balance;

  /// Icon emoji for display
  final String icon;

  /// Color hex code
  final String color;

  /// Is wallet active?
  final bool isActive;

  /// Creation timestamp
  final DateTime createdAt;
  const WalletData({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.icon,
    required this.color,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<int>($WalletsTable.$convertertype.toSql(type));
    }
    map['balance'] = Variable<double>(balance);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<String>(color);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WalletsCompanion toCompanion(bool nullToAbsent) {
    return WalletsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      balance: Value(balance),
      icon: Value(icon),
      color: Value(color),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory WalletData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalletData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: $WalletsTable.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      balance: serializer.fromJson<double>(json['balance']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<String>(json['color']),
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
      'type': serializer.toJson<int>($WalletsTable.$convertertype.toJson(type)),
      'balance': serializer.toJson<double>(balance),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<String>(color),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WalletData copyWith({
    int? id,
    String? name,
    WalletType? type,
    double? balance,
    String? icon,
    String? color,
    bool? isActive,
    DateTime? createdAt,
  }) => WalletData(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    balance: balance ?? this.balance,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  WalletData copyWithCompanion(WalletsCompanion data) {
    return WalletData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      balance: data.balance.present ? data.balance.value : this.balance,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalletData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('balance: $balance, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, type, balance, icon, color, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletData &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.balance == this.balance &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class WalletsCompanion extends UpdateCompanion<WalletData> {
  final Value<int> id;
  final Value<String> name;
  final Value<WalletType> type;
  final Value<double> balance;
  final Value<String> icon;
  final Value<String> color;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const WalletsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.balance = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WalletsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required WalletType type,
    this.balance = const Value.absent(),
    required String icon,
    required String color,
    this.isActive = const Value.absent(),
    required DateTime createdAt,
  }) : name = Value(name),
       type = Value(type),
       icon = Value(icon),
       color = Value(color),
       createdAt = Value(createdAt);
  static Insertable<WalletData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? type,
    Expression<double>? balance,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (balance != null) 'balance': balance,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WalletsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<WalletType>? type,
    Value<double>? balance,
    Value<String>? icon,
    Value<String>? color,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return WalletsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      icon: icon ?? this.icon,
      color: color ?? this.color,
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
        $WalletsTable.$convertertype.toSql(type.value),
      );
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
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
    return (StringBuffer('WalletsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('balance: $balance, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ShieldItemsTable extends ShieldItems
    with TableInfo<$ShieldItemsTable, ShieldItemData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShieldItemsTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<ShieldType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<ShieldType>($ShieldItemsTable.$convertertype);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RecurrenceFrequency, int>
  frequency = GeneratedColumn<int>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  ).withConverter<RecurrenceFrequency>($ShieldItemsTable.$converterfrequency);
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPaidMeta = const VerificationMeta('isPaid');
  @override
  late final GeneratedColumn<bool> isPaid = GeneratedColumn<bool>(
    'is_paid',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_paid" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    type,
    name,
    amount,
    frequency,
    dueDate,
    isPaid,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shield_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShieldItemData> instance, {
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
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('is_paid')) {
      context.handle(
        _isPaidMeta,
        isPaid.isAcceptableOrUnknown(data['is_paid']!, _isPaidMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
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
  ShieldItemData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShieldItemData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: $ShieldItemsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      frequency: $ShieldItemsTable.$converterfrequency.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}frequency'],
        )!,
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      )!,
      isPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_paid'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ShieldItemsTable createAlias(String alias) {
    return $ShieldItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ShieldType, int, int> $convertertype =
      const EnumIndexConverter<ShieldType>(ShieldType.values);
  static JsonTypeConverter2<RecurrenceFrequency, int, int> $converterfrequency =
      const EnumIndexConverter<RecurrenceFrequency>(RecurrenceFrequency.values);
}

class ShieldItemData extends DataClass implements Insertable<ShieldItemData> {
  final int id;

  /// Type of shield item
  final ShieldType type;

  /// Display name
  final String name;

  /// Amount in FCFA
  final double amount;

  /// How often does this recur?
  final RecurrenceFrequency frequency;

  /// Next due date
  final DateTime dueDate;

  /// Has been paid this period?
  final bool isPaid;

  /// Is this shield item active?
  final bool isActive;

  /// Creation timestamp
  final DateTime createdAt;
  const ShieldItemData({
    required this.id,
    required this.type,
    required this.name,
    required this.amount,
    required this.frequency,
    required this.dueDate,
    required this.isPaid,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['type'] = Variable<int>($ShieldItemsTable.$convertertype.toSql(type));
    }
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<double>(amount);
    {
      map['frequency'] = Variable<int>(
        $ShieldItemsTable.$converterfrequency.toSql(frequency),
      );
    }
    map['due_date'] = Variable<DateTime>(dueDate);
    map['is_paid'] = Variable<bool>(isPaid);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ShieldItemsCompanion toCompanion(bool nullToAbsent) {
    return ShieldItemsCompanion(
      id: Value(id),
      type: Value(type),
      name: Value(name),
      amount: Value(amount),
      frequency: Value(frequency),
      dueDate: Value(dueDate),
      isPaid: Value(isPaid),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory ShieldItemData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShieldItemData(
      id: serializer.fromJson<int>(json['id']),
      type: $ShieldItemsTable.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<double>(json['amount']),
      frequency: $ShieldItemsTable.$converterfrequency.fromJson(
        serializer.fromJson<int>(json['frequency']),
      ),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
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
      'type': serializer.toJson<int>(
        $ShieldItemsTable.$convertertype.toJson(type),
      ),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<double>(amount),
      'frequency': serializer.toJson<int>(
        $ShieldItemsTable.$converterfrequency.toJson(frequency),
      ),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'isPaid': serializer.toJson<bool>(isPaid),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ShieldItemData copyWith({
    int? id,
    ShieldType? type,
    String? name,
    double? amount,
    RecurrenceFrequency? frequency,
    DateTime? dueDate,
    bool? isPaid,
    bool? isActive,
    DateTime? createdAt,
  }) => ShieldItemData(
    id: id ?? this.id,
    type: type ?? this.type,
    name: name ?? this.name,
    amount: amount ?? this.amount,
    frequency: frequency ?? this.frequency,
    dueDate: dueDate ?? this.dueDate,
    isPaid: isPaid ?? this.isPaid,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  ShieldItemData copyWithCompanion(ShieldItemsCompanion data) {
    return ShieldItemData(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      name: data.name.present ? data.name.value : this.name,
      amount: data.amount.present ? data.amount.value : this.amount,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      isPaid: data.isPaid.present ? data.isPaid.value : this.isPaid,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShieldItemData(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('frequency: $frequency, ')
          ..write('dueDate: $dueDate, ')
          ..write('isPaid: $isPaid, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    name,
    amount,
    frequency,
    dueDate,
    isPaid,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShieldItemData &&
          other.id == this.id &&
          other.type == this.type &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.frequency == this.frequency &&
          other.dueDate == this.dueDate &&
          other.isPaid == this.isPaid &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class ShieldItemsCompanion extends UpdateCompanion<ShieldItemData> {
  final Value<int> id;
  final Value<ShieldType> type;
  final Value<String> name;
  final Value<double> amount;
  final Value<RecurrenceFrequency> frequency;
  final Value<DateTime> dueDate;
  final Value<bool> isPaid;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const ShieldItemsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.frequency = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.isPaid = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ShieldItemsCompanion.insert({
    this.id = const Value.absent(),
    required ShieldType type,
    required String name,
    required double amount,
    required RecurrenceFrequency frequency,
    required DateTime dueDate,
    this.isPaid = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
  }) : type = Value(type),
       name = Value(name),
       amount = Value(amount),
       frequency = Value(frequency),
       dueDate = Value(dueDate),
       createdAt = Value(createdAt);
  static Insertable<ShieldItemData> custom({
    Expression<int>? id,
    Expression<int>? type,
    Expression<String>? name,
    Expression<double>? amount,
    Expression<int>? frequency,
    Expression<DateTime>? dueDate,
    Expression<bool>? isPaid,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (frequency != null) 'frequency': frequency,
      if (dueDate != null) 'due_date': dueDate,
      if (isPaid != null) 'is_paid': isPaid,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ShieldItemsCompanion copyWith({
    Value<int>? id,
    Value<ShieldType>? type,
    Value<String>? name,
    Value<double>? amount,
    Value<RecurrenceFrequency>? frequency,
    Value<DateTime>? dueDate,
    Value<bool>? isPaid,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return ShieldItemsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      dueDate: dueDate ?? this.dueDate,
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
    if (type.present) {
      map['type'] = Variable<int>(
        $ShieldItemsTable.$convertertype.toSql(type.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<int>(
        $ShieldItemsTable.$converterfrequency.toSql(frequency.value),
      );
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
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
    return (StringBuffer('ShieldItemsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('frequency: $frequency, ')
          ..write('dueDate: $dueDate, ')
          ..write('isPaid: $isPaid, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DailySnapshotsTable extends DailySnapshots
    with TableInfo<$DailySnapshotsTable, DailySnapshotData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailySnapshotsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dailyCapMeta = const VerificationMeta(
    'dailyCap',
  );
  @override
  late final GeneratedColumn<double> dailyCap = GeneratedColumn<double>(
    'daily_cap',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalSpentMeta = const VerificationMeta(
    'totalSpent',
  );
  @override
  late final GeneratedColumn<double> totalSpent = GeneratedColumn<double>(
    'total_spent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _remainingMeta = const VerificationMeta(
    'remaining',
  );
  @override
  late final GeneratedColumn<double> remaining = GeneratedColumn<double>(
    'remaining',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carryOverMeta = const VerificationMeta(
    'carryOver',
  );
  @override
  late final GeneratedColumn<double> carryOver = GeneratedColumn<double>(
    'carry_over',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _wasCarriedOverMeta = const VerificationMeta(
    'wasCarriedOver',
  );
  @override
  late final GeneratedColumn<bool> wasCarriedOver = GeneratedColumn<bool>(
    'was_carried_over',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_carried_over" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    date,
    dailyCap,
    totalSpent,
    remaining,
    carryOver,
    wasCarriedOver,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailySnapshotData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('daily_cap')) {
      context.handle(
        _dailyCapMeta,
        dailyCap.isAcceptableOrUnknown(data['daily_cap']!, _dailyCapMeta),
      );
    } else if (isInserting) {
      context.missing(_dailyCapMeta);
    }
    if (data.containsKey('total_spent')) {
      context.handle(
        _totalSpentMeta,
        totalSpent.isAcceptableOrUnknown(data['total_spent']!, _totalSpentMeta),
      );
    }
    if (data.containsKey('remaining')) {
      context.handle(
        _remainingMeta,
        remaining.isAcceptableOrUnknown(data['remaining']!, _remainingMeta),
      );
    } else if (isInserting) {
      context.missing(_remainingMeta);
    }
    if (data.containsKey('carry_over')) {
      context.handle(
        _carryOverMeta,
        carryOver.isAcceptableOrUnknown(data['carry_over']!, _carryOverMeta),
      );
    }
    if (data.containsKey('was_carried_over')) {
      context.handle(
        _wasCarriedOverMeta,
        wasCarriedOver.isAcceptableOrUnknown(
          data['was_carried_over']!,
          _wasCarriedOverMeta,
        ),
      );
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
  DailySnapshotData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailySnapshotData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      dailyCap: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}daily_cap'],
      )!,
      totalSpent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_spent'],
      )!,
      remaining: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}remaining'],
      )!,
      carryOver: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carry_over'],
      )!,
      wasCarriedOver: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_carried_over'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DailySnapshotsTable createAlias(String alias) {
    return $DailySnapshotsTable(attachedDatabase, alias);
  }
}

class DailySnapshotData extends DataClass
    implements Insertable<DailySnapshotData> {
  final int id;

  /// The date this snapshot applies to
  final DateTime date;

  /// Calculated daily cap for this day
  final double dailyCap;

  /// Total spent on this day
  final double totalSpent;

  /// Remaining from daily cap
  final double remaining;

  /// Carry over from previous day
  final double carryOver;

  /// Was previous day's money carried over?
  final bool wasCarriedOver;

  /// Creation timestamp
  final DateTime createdAt;
  const DailySnapshotData({
    required this.id,
    required this.date,
    required this.dailyCap,
    required this.totalSpent,
    required this.remaining,
    required this.carryOver,
    required this.wasCarriedOver,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['daily_cap'] = Variable<double>(dailyCap);
    map['total_spent'] = Variable<double>(totalSpent);
    map['remaining'] = Variable<double>(remaining);
    map['carry_over'] = Variable<double>(carryOver);
    map['was_carried_over'] = Variable<bool>(wasCarriedOver);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DailySnapshotsCompanion toCompanion(bool nullToAbsent) {
    return DailySnapshotsCompanion(
      id: Value(id),
      date: Value(date),
      dailyCap: Value(dailyCap),
      totalSpent: Value(totalSpent),
      remaining: Value(remaining),
      carryOver: Value(carryOver),
      wasCarriedOver: Value(wasCarriedOver),
      createdAt: Value(createdAt),
    );
  }

  factory DailySnapshotData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailySnapshotData(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      dailyCap: serializer.fromJson<double>(json['dailyCap']),
      totalSpent: serializer.fromJson<double>(json['totalSpent']),
      remaining: serializer.fromJson<double>(json['remaining']),
      carryOver: serializer.fromJson<double>(json['carryOver']),
      wasCarriedOver: serializer.fromJson<bool>(json['wasCarriedOver']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'dailyCap': serializer.toJson<double>(dailyCap),
      'totalSpent': serializer.toJson<double>(totalSpent),
      'remaining': serializer.toJson<double>(remaining),
      'carryOver': serializer.toJson<double>(carryOver),
      'wasCarriedOver': serializer.toJson<bool>(wasCarriedOver),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DailySnapshotData copyWith({
    int? id,
    DateTime? date,
    double? dailyCap,
    double? totalSpent,
    double? remaining,
    double? carryOver,
    bool? wasCarriedOver,
    DateTime? createdAt,
  }) => DailySnapshotData(
    id: id ?? this.id,
    date: date ?? this.date,
    dailyCap: dailyCap ?? this.dailyCap,
    totalSpent: totalSpent ?? this.totalSpent,
    remaining: remaining ?? this.remaining,
    carryOver: carryOver ?? this.carryOver,
    wasCarriedOver: wasCarriedOver ?? this.wasCarriedOver,
    createdAt: createdAt ?? this.createdAt,
  );
  DailySnapshotData copyWithCompanion(DailySnapshotsCompanion data) {
    return DailySnapshotData(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      dailyCap: data.dailyCap.present ? data.dailyCap.value : this.dailyCap,
      totalSpent: data.totalSpent.present
          ? data.totalSpent.value
          : this.totalSpent,
      remaining: data.remaining.present ? data.remaining.value : this.remaining,
      carryOver: data.carryOver.present ? data.carryOver.value : this.carryOver,
      wasCarriedOver: data.wasCarriedOver.present
          ? data.wasCarriedOver.value
          : this.wasCarriedOver,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailySnapshotData(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('dailyCap: $dailyCap, ')
          ..write('totalSpent: $totalSpent, ')
          ..write('remaining: $remaining, ')
          ..write('carryOver: $carryOver, ')
          ..write('wasCarriedOver: $wasCarriedOver, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    dailyCap,
    totalSpent,
    remaining,
    carryOver,
    wasCarriedOver,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailySnapshotData &&
          other.id == this.id &&
          other.date == this.date &&
          other.dailyCap == this.dailyCap &&
          other.totalSpent == this.totalSpent &&
          other.remaining == this.remaining &&
          other.carryOver == this.carryOver &&
          other.wasCarriedOver == this.wasCarriedOver &&
          other.createdAt == this.createdAt);
}

class DailySnapshotsCompanion extends UpdateCompanion<DailySnapshotData> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<double> dailyCap;
  final Value<double> totalSpent;
  final Value<double> remaining;
  final Value<double> carryOver;
  final Value<bool> wasCarriedOver;
  final Value<DateTime> createdAt;
  const DailySnapshotsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.dailyCap = const Value.absent(),
    this.totalSpent = const Value.absent(),
    this.remaining = const Value.absent(),
    this.carryOver = const Value.absent(),
    this.wasCarriedOver = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DailySnapshotsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required double dailyCap,
    this.totalSpent = const Value.absent(),
    required double remaining,
    this.carryOver = const Value.absent(),
    this.wasCarriedOver = const Value.absent(),
    required DateTime createdAt,
  }) : date = Value(date),
       dailyCap = Value(dailyCap),
       remaining = Value(remaining),
       createdAt = Value(createdAt);
  static Insertable<DailySnapshotData> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<double>? dailyCap,
    Expression<double>? totalSpent,
    Expression<double>? remaining,
    Expression<double>? carryOver,
    Expression<bool>? wasCarriedOver,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (dailyCap != null) 'daily_cap': dailyCap,
      if (totalSpent != null) 'total_spent': totalSpent,
      if (remaining != null) 'remaining': remaining,
      if (carryOver != null) 'carry_over': carryOver,
      if (wasCarriedOver != null) 'was_carried_over': wasCarriedOver,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DailySnapshotsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<double>? dailyCap,
    Value<double>? totalSpent,
    Value<double>? remaining,
    Value<double>? carryOver,
    Value<bool>? wasCarriedOver,
    Value<DateTime>? createdAt,
  }) {
    return DailySnapshotsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      dailyCap: dailyCap ?? this.dailyCap,
      totalSpent: totalSpent ?? this.totalSpent,
      remaining: remaining ?? this.remaining,
      carryOver: carryOver ?? this.carryOver,
      wasCarriedOver: wasCarriedOver ?? this.wasCarriedOver,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (dailyCap.present) {
      map['daily_cap'] = Variable<double>(dailyCap.value);
    }
    if (totalSpent.present) {
      map['total_spent'] = Variable<double>(totalSpent.value);
    }
    if (remaining.present) {
      map['remaining'] = Variable<double>(remaining.value);
    }
    if (carryOver.present) {
      map['carry_over'] = Variable<double>(carryOver.value);
    }
    if (wasCarriedOver.present) {
      map['was_carried_over'] = Variable<bool>(wasCarriedOver.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailySnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('dailyCap: $dailyCap, ')
          ..write('totalSpent: $totalSpent, ')
          ..write('remaining: $remaining, ')
          ..write('carryOver: $carryOver, ')
          ..write('wasCarriedOver: $wasCarriedOver, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('FCFA'),
  );
  static const VerificationMeta _darkModeMeta = const VerificationMeta(
    'darkMode',
  );
  @override
  late final GeneratedColumn<bool> darkMode = GeneratedColumn<bool>(
    'dark_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dark_mode" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _privacyModeMeta = const VerificationMeta(
    'privacyMode',
  );
  @override
  late final GeneratedColumn<bool> privacyMode = GeneratedColumn<bool>(
    'privacy_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("privacy_mode" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _shadowSavingsRateMeta = const VerificationMeta(
    'shadowSavingsRate',
  );
  @override
  late final GeneratedColumn<double> shadowSavingsRate =
      GeneratedColumn<double>(
        'shadow_savings_rate',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.1),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    currency,
    darkMode,
    privacyMode,
    shadowSavingsRate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('dark_mode')) {
      context.handle(
        _darkModeMeta,
        darkMode.isAcceptableOrUnknown(data['dark_mode']!, _darkModeMeta),
      );
    }
    if (data.containsKey('privacy_mode')) {
      context.handle(
        _privacyModeMeta,
        privacyMode.isAcceptableOrUnknown(
          data['privacy_mode']!,
          _privacyModeMeta,
        ),
      );
    }
    if (data.containsKey('shadow_savings_rate')) {
      context.handle(
        _shadowSavingsRateMeta,
        shadowSavingsRate.isAcceptableOrUnknown(
          data['shadow_savings_rate']!,
          _shadowSavingsRateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      darkMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dark_mode'],
      )!,
      privacyMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}privacy_mode'],
      )!,
      shadowSavingsRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}shadow_savings_rate'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingData extends DataClass implements Insertable<SettingData> {
  final int id;

  /// Currency code (default FCFA)
  final String currency;

  /// Dark mode enabled?
  final bool darkMode;

  /// Privacy mode (blur amounts)?
  final bool privacyMode;

  /// Shadow savings rate (0.0 to 1.0)
  final double shadowSavingsRate;
  const SettingData({
    required this.id,
    required this.currency,
    required this.darkMode,
    required this.privacyMode,
    required this.shadowSavingsRate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['currency'] = Variable<String>(currency);
    map['dark_mode'] = Variable<bool>(darkMode);
    map['privacy_mode'] = Variable<bool>(privacyMode);
    map['shadow_savings_rate'] = Variable<double>(shadowSavingsRate);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      currency: Value(currency),
      darkMode: Value(darkMode),
      privacyMode: Value(privacyMode),
      shadowSavingsRate: Value(shadowSavingsRate),
    );
  }

  factory SettingData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingData(
      id: serializer.fromJson<int>(json['id']),
      currency: serializer.fromJson<String>(json['currency']),
      darkMode: serializer.fromJson<bool>(json['darkMode']),
      privacyMode: serializer.fromJson<bool>(json['privacyMode']),
      shadowSavingsRate: serializer.fromJson<double>(json['shadowSavingsRate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'currency': serializer.toJson<String>(currency),
      'darkMode': serializer.toJson<bool>(darkMode),
      'privacyMode': serializer.toJson<bool>(privacyMode),
      'shadowSavingsRate': serializer.toJson<double>(shadowSavingsRate),
    };
  }

  SettingData copyWith({
    int? id,
    String? currency,
    bool? darkMode,
    bool? privacyMode,
    double? shadowSavingsRate,
  }) => SettingData(
    id: id ?? this.id,
    currency: currency ?? this.currency,
    darkMode: darkMode ?? this.darkMode,
    privacyMode: privacyMode ?? this.privacyMode,
    shadowSavingsRate: shadowSavingsRate ?? this.shadowSavingsRate,
  );
  SettingData copyWithCompanion(SettingsCompanion data) {
    return SettingData(
      id: data.id.present ? data.id.value : this.id,
      currency: data.currency.present ? data.currency.value : this.currency,
      darkMode: data.darkMode.present ? data.darkMode.value : this.darkMode,
      privacyMode: data.privacyMode.present
          ? data.privacyMode.value
          : this.privacyMode,
      shadowSavingsRate: data.shadowSavingsRate.present
          ? data.shadowSavingsRate.value
          : this.shadowSavingsRate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingData(')
          ..write('id: $id, ')
          ..write('currency: $currency, ')
          ..write('darkMode: $darkMode, ')
          ..write('privacyMode: $privacyMode, ')
          ..write('shadowSavingsRate: $shadowSavingsRate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, currency, darkMode, privacyMode, shadowSavingsRate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingData &&
          other.id == this.id &&
          other.currency == this.currency &&
          other.darkMode == this.darkMode &&
          other.privacyMode == this.privacyMode &&
          other.shadowSavingsRate == this.shadowSavingsRate);
}

class SettingsCompanion extends UpdateCompanion<SettingData> {
  final Value<int> id;
  final Value<String> currency;
  final Value<bool> darkMode;
  final Value<bool> privacyMode;
  final Value<double> shadowSavingsRate;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.currency = const Value.absent(),
    this.darkMode = const Value.absent(),
    this.privacyMode = const Value.absent(),
    this.shadowSavingsRate = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    this.currency = const Value.absent(),
    this.darkMode = const Value.absent(),
    this.privacyMode = const Value.absent(),
    this.shadowSavingsRate = const Value.absent(),
  });
  static Insertable<SettingData> custom({
    Expression<int>? id,
    Expression<String>? currency,
    Expression<bool>? darkMode,
    Expression<bool>? privacyMode,
    Expression<double>? shadowSavingsRate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currency != null) 'currency': currency,
      if (darkMode != null) 'dark_mode': darkMode,
      if (privacyMode != null) 'privacy_mode': privacyMode,
      if (shadowSavingsRate != null) 'shadow_savings_rate': shadowSavingsRate,
    });
  }

  SettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? currency,
    Value<bool>? darkMode,
    Value<bool>? privacyMode,
    Value<double>? shadowSavingsRate,
  }) {
    return SettingsCompanion(
      id: id ?? this.id,
      currency: currency ?? this.currency,
      darkMode: darkMode ?? this.darkMode,
      privacyMode: privacyMode ?? this.privacyMode,
      shadowSavingsRate: shadowSavingsRate ?? this.shadowSavingsRate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (darkMode.present) {
      map['dark_mode'] = Variable<bool>(darkMode.value);
    }
    if (privacyMode.present) {
      map['privacy_mode'] = Variable<bool>(privacyMode.value);
    }
    if (shadowSavingsRate.present) {
      map['shadow_savings_rate'] = Variable<double>(shadowSavingsRate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('currency: $currency, ')
          ..write('darkMode: $darkMode, ')
          ..write('privacyMode: $privacyMode, ')
          ..write('shadowSavingsRate: $shadowSavingsRate')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  _$AppDatabase.connect(DatabaseConnection c) : super.connect(c);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $WalletsTable wallets = $WalletsTable(this);
  late final $ShieldItemsTable shieldItems = $ShieldItemsTable(this);
  late final $DailySnapshotsTable dailySnapshots = $DailySnapshotsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    transactions,
    wallets,
    shieldItems,
    dailySnapshots,
    settings,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      required TransactionType type,
      required DateTime date,
      required double amount,
      required String category,
      required WalletType sourceWallet,
      Value<WalletType> destinationWallet,
      Value<String?> note,
      Value<bool> isShieldRelated,
      required DateTime createdAt,
      Value<String?> incomeFrequency,
      Value<double> shadowSavings,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<TransactionType> type,
      Value<DateTime> date,
      Value<double> amount,
      Value<String> category,
      Value<WalletType> sourceWallet,
      Value<WalletType> destinationWallet,
      Value<String?> note,
      Value<bool> isShieldRelated,
      Value<DateTime> createdAt,
      Value<String?> incomeFrequency,
      Value<double> shadowSavings,
    });

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
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TransactionType, TransactionType, int>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WalletType, WalletType, int>
  get sourceWallet => $composableBuilder(
    column: $table.sourceWallet,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<WalletType, WalletType, int>
  get destinationWallet => $composableBuilder(
    column: $table.destinationWallet,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isShieldRelated => $composableBuilder(
    column: $table.isShieldRelated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get incomeFrequency => $composableBuilder(
    column: $table.incomeFrequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get shadowSavings => $composableBuilder(
    column: $table.shadowSavings,
    builder: (column) => ColumnFilters(column),
  );
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
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceWallet => $composableBuilder(
    column: $table.sourceWallet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get destinationWallet => $composableBuilder(
    column: $table.destinationWallet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isShieldRelated => $composableBuilder(
    column: $table.isShieldRelated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get incomeFrequency => $composableBuilder(
    column: $table.incomeFrequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get shadowSavings => $composableBuilder(
    column: $table.shadowSavings,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumnWithTypeConverter<TransactionType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WalletType, int> get sourceWallet =>
      $composableBuilder(
        column: $table.sourceWallet,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<WalletType, int> get destinationWallet =>
      $composableBuilder(
        column: $table.destinationWallet,
        builder: (column) => column,
      );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get isShieldRelated => $composableBuilder(
    column: $table.isShieldRelated,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get incomeFrequency => $composableBuilder(
    column: $table.incomeFrequency,
    builder: (column) => column,
  );

  GeneratedColumn<double> get shadowSavings => $composableBuilder(
    column: $table.shadowSavings,
    builder: (column) => column,
  );
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          TransactionData,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            TransactionData,
            BaseReferences<_$AppDatabase, $TransactionsTable, TransactionData>,
          ),
          TransactionData,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<TransactionType> type = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<WalletType> sourceWallet = const Value.absent(),
                Value<WalletType> destinationWallet = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> isShieldRelated = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> incomeFrequency = const Value.absent(),
                Value<double> shadowSavings = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                type: type,
                date: date,
                amount: amount,
                category: category,
                sourceWallet: sourceWallet,
                destinationWallet: destinationWallet,
                note: note,
                isShieldRelated: isShieldRelated,
                createdAt: createdAt,
                incomeFrequency: incomeFrequency,
                shadowSavings: shadowSavings,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required TransactionType type,
                required DateTime date,
                required double amount,
                required String category,
                required WalletType sourceWallet,
                Value<WalletType> destinationWallet = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> isShieldRelated = const Value.absent(),
                required DateTime createdAt,
                Value<String?> incomeFrequency = const Value.absent(),
                Value<double> shadowSavings = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                type: type,
                date: date,
                amount: amount,
                category: category,
                sourceWallet: sourceWallet,
                destinationWallet: destinationWallet,
                note: note,
                isShieldRelated: isShieldRelated,
                createdAt: createdAt,
                incomeFrequency: incomeFrequency,
                shadowSavings: shadowSavings,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      TransactionData,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        TransactionData,
        BaseReferences<_$AppDatabase, $TransactionsTable, TransactionData>,
      ),
      TransactionData,
      PrefetchHooks Function()
    >;
typedef $$WalletsTableCreateCompanionBuilder =
    WalletsCompanion Function({
      Value<int> id,
      required String name,
      required WalletType type,
      Value<double> balance,
      required String icon,
      required String color,
      Value<bool> isActive,
      required DateTime createdAt,
    });
typedef $$WalletsTableUpdateCompanionBuilder =
    WalletsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<WalletType> type,
      Value<double> balance,
      Value<String> icon,
      Value<String> color,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });

class $$WalletsTableFilterComposer
    extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<WalletType, WalletType, int> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WalletsTableOrderingComposer
    extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableOrderingComposer({
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

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WalletsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<WalletType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WalletsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalletsTable,
          WalletData,
          $$WalletsTableFilterComposer,
          $$WalletsTableOrderingComposer,
          $$WalletsTableAnnotationComposer,
          $$WalletsTableCreateCompanionBuilder,
          $$WalletsTableUpdateCompanionBuilder,
          (
            WalletData,
            BaseReferences<_$AppDatabase, $WalletsTable, WalletData>,
          ),
          WalletData,
          PrefetchHooks Function()
        > {
  $$WalletsTableTableManager(_$AppDatabase db, $WalletsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalletsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalletsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WalletsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<WalletType> type = const Value.absent(),
                Value<double> balance = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WalletsCompanion(
                id: id,
                name: name,
                type: type,
                balance: balance,
                icon: icon,
                color: color,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required WalletType type,
                Value<double> balance = const Value.absent(),
                required String icon,
                required String color,
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
              }) => WalletsCompanion.insert(
                id: id,
                name: name,
                type: type,
                balance: balance,
                icon: icon,
                color: color,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WalletsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalletsTable,
      WalletData,
      $$WalletsTableFilterComposer,
      $$WalletsTableOrderingComposer,
      $$WalletsTableAnnotationComposer,
      $$WalletsTableCreateCompanionBuilder,
      $$WalletsTableUpdateCompanionBuilder,
      (WalletData, BaseReferences<_$AppDatabase, $WalletsTable, WalletData>),
      WalletData,
      PrefetchHooks Function()
    >;
typedef $$ShieldItemsTableCreateCompanionBuilder =
    ShieldItemsCompanion Function({
      Value<int> id,
      required ShieldType type,
      required String name,
      required double amount,
      required RecurrenceFrequency frequency,
      required DateTime dueDate,
      Value<bool> isPaid,
      Value<bool> isActive,
      required DateTime createdAt,
    });
typedef $$ShieldItemsTableUpdateCompanionBuilder =
    ShieldItemsCompanion Function({
      Value<int> id,
      Value<ShieldType> type,
      Value<String> name,
      Value<double> amount,
      Value<RecurrenceFrequency> frequency,
      Value<DateTime> dueDate,
      Value<bool> isPaid,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });

class $$ShieldItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ShieldItemsTable> {
  $$ShieldItemsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<ShieldType, ShieldType, int> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RecurrenceFrequency, RecurrenceFrequency, int>
  get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPaid => $composableBuilder(
    column: $table.isPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShieldItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShieldItemsTable> {
  $$ShieldItemsTableOrderingComposer({
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

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPaid => $composableBuilder(
    column: $table.isPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShieldItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShieldItemsTable> {
  $$ShieldItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ShieldType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RecurrenceFrequency, int> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<bool> get isPaid =>
      $composableBuilder(column: $table.isPaid, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ShieldItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShieldItemsTable,
          ShieldItemData,
          $$ShieldItemsTableFilterComposer,
          $$ShieldItemsTableOrderingComposer,
          $$ShieldItemsTableAnnotationComposer,
          $$ShieldItemsTableCreateCompanionBuilder,
          $$ShieldItemsTableUpdateCompanionBuilder,
          (
            ShieldItemData,
            BaseReferences<_$AppDatabase, $ShieldItemsTable, ShieldItemData>,
          ),
          ShieldItemData,
          PrefetchHooks Function()
        > {
  $$ShieldItemsTableTableManager(_$AppDatabase db, $ShieldItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShieldItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShieldItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShieldItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<ShieldType> type = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<RecurrenceFrequency> frequency = const Value.absent(),
                Value<DateTime> dueDate = const Value.absent(),
                Value<bool> isPaid = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ShieldItemsCompanion(
                id: id,
                type: type,
                name: name,
                amount: amount,
                frequency: frequency,
                dueDate: dueDate,
                isPaid: isPaid,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required ShieldType type,
                required String name,
                required double amount,
                required RecurrenceFrequency frequency,
                required DateTime dueDate,
                Value<bool> isPaid = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
              }) => ShieldItemsCompanion.insert(
                id: id,
                type: type,
                name: name,
                amount: amount,
                frequency: frequency,
                dueDate: dueDate,
                isPaid: isPaid,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShieldItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShieldItemsTable,
      ShieldItemData,
      $$ShieldItemsTableFilterComposer,
      $$ShieldItemsTableOrderingComposer,
      $$ShieldItemsTableAnnotationComposer,
      $$ShieldItemsTableCreateCompanionBuilder,
      $$ShieldItemsTableUpdateCompanionBuilder,
      (
        ShieldItemData,
        BaseReferences<_$AppDatabase, $ShieldItemsTable, ShieldItemData>,
      ),
      ShieldItemData,
      PrefetchHooks Function()
    >;
typedef $$DailySnapshotsTableCreateCompanionBuilder =
    DailySnapshotsCompanion Function({
      Value<int> id,
      required DateTime date,
      required double dailyCap,
      Value<double> totalSpent,
      required double remaining,
      Value<double> carryOver,
      Value<bool> wasCarriedOver,
      required DateTime createdAt,
    });
typedef $$DailySnapshotsTableUpdateCompanionBuilder =
    DailySnapshotsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<double> dailyCap,
      Value<double> totalSpent,
      Value<double> remaining,
      Value<double> carryOver,
      Value<bool> wasCarriedOver,
      Value<DateTime> createdAt,
    });

class $$DailySnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $DailySnapshotsTable> {
  $$DailySnapshotsTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dailyCap => $composableBuilder(
    column: $table.dailyCap,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalSpent => $composableBuilder(
    column: $table.totalSpent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get remaining => $composableBuilder(
    column: $table.remaining,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carryOver => $composableBuilder(
    column: $table.carryOver,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasCarriedOver => $composableBuilder(
    column: $table.wasCarriedOver,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailySnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailySnapshotsTable> {
  $$DailySnapshotsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dailyCap => $composableBuilder(
    column: $table.dailyCap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalSpent => $composableBuilder(
    column: $table.totalSpent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get remaining => $composableBuilder(
    column: $table.remaining,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carryOver => $composableBuilder(
    column: $table.carryOver,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasCarriedOver => $composableBuilder(
    column: $table.wasCarriedOver,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailySnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailySnapshotsTable> {
  $$DailySnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get dailyCap =>
      $composableBuilder(column: $table.dailyCap, builder: (column) => column);

  GeneratedColumn<double> get totalSpent => $composableBuilder(
    column: $table.totalSpent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get remaining =>
      $composableBuilder(column: $table.remaining, builder: (column) => column);

  GeneratedColumn<double> get carryOver =>
      $composableBuilder(column: $table.carryOver, builder: (column) => column);

  GeneratedColumn<bool> get wasCarriedOver => $composableBuilder(
    column: $table.wasCarriedOver,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DailySnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailySnapshotsTable,
          DailySnapshotData,
          $$DailySnapshotsTableFilterComposer,
          $$DailySnapshotsTableOrderingComposer,
          $$DailySnapshotsTableAnnotationComposer,
          $$DailySnapshotsTableCreateCompanionBuilder,
          $$DailySnapshotsTableUpdateCompanionBuilder,
          (
            DailySnapshotData,
            BaseReferences<
              _$AppDatabase,
              $DailySnapshotsTable,
              DailySnapshotData
            >,
          ),
          DailySnapshotData,
          PrefetchHooks Function()
        > {
  $$DailySnapshotsTableTableManager(
    _$AppDatabase db,
    $DailySnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailySnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailySnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailySnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> dailyCap = const Value.absent(),
                Value<double> totalSpent = const Value.absent(),
                Value<double> remaining = const Value.absent(),
                Value<double> carryOver = const Value.absent(),
                Value<bool> wasCarriedOver = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DailySnapshotsCompanion(
                id: id,
                date: date,
                dailyCap: dailyCap,
                totalSpent: totalSpent,
                remaining: remaining,
                carryOver: carryOver,
                wasCarriedOver: wasCarriedOver,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required double dailyCap,
                Value<double> totalSpent = const Value.absent(),
                required double remaining,
                Value<double> carryOver = const Value.absent(),
                Value<bool> wasCarriedOver = const Value.absent(),
                required DateTime createdAt,
              }) => DailySnapshotsCompanion.insert(
                id: id,
                date: date,
                dailyCap: dailyCap,
                totalSpent: totalSpent,
                remaining: remaining,
                carryOver: carryOver,
                wasCarriedOver: wasCarriedOver,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailySnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailySnapshotsTable,
      DailySnapshotData,
      $$DailySnapshotsTableFilterComposer,
      $$DailySnapshotsTableOrderingComposer,
      $$DailySnapshotsTableAnnotationComposer,
      $$DailySnapshotsTableCreateCompanionBuilder,
      $$DailySnapshotsTableUpdateCompanionBuilder,
      (
        DailySnapshotData,
        BaseReferences<_$AppDatabase, $DailySnapshotsTable, DailySnapshotData>,
      ),
      DailySnapshotData,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      Value<int> id,
      Value<String> currency,
      Value<bool> darkMode,
      Value<bool> privacyMode,
      Value<double> shadowSavingsRate,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<int> id,
      Value<String> currency,
      Value<bool> darkMode,
      Value<bool> privacyMode,
      Value<double> shadowSavingsRate,
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
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get darkMode => $composableBuilder(
    column: $table.darkMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get privacyMode => $composableBuilder(
    column: $table.privacyMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get shadowSavingsRate => $composableBuilder(
    column: $table.shadowSavingsRate,
    builder: (column) => ColumnFilters(column),
  );
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
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get darkMode => $composableBuilder(
    column: $table.darkMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get privacyMode => $composableBuilder(
    column: $table.privacyMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get shadowSavingsRate => $composableBuilder(
    column: $table.shadowSavingsRate,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<bool> get darkMode =>
      $composableBuilder(column: $table.darkMode, builder: (column) => column);

  GeneratedColumn<bool> get privacyMode => $composableBuilder(
    column: $table.privacyMode,
    builder: (column) => column,
  );

  GeneratedColumn<double> get shadowSavingsRate => $composableBuilder(
    column: $table.shadowSavingsRate,
    builder: (column) => column,
  );
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingData,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingData,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingData>,
          ),
          SettingData,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<bool> darkMode = const Value.absent(),
                Value<bool> privacyMode = const Value.absent(),
                Value<double> shadowSavingsRate = const Value.absent(),
              }) => SettingsCompanion(
                id: id,
                currency: currency,
                darkMode: darkMode,
                privacyMode: privacyMode,
                shadowSavingsRate: shadowSavingsRate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<bool> darkMode = const Value.absent(),
                Value<bool> privacyMode = const Value.absent(),
                Value<double> shadowSavingsRate = const Value.absent(),
              }) => SettingsCompanion.insert(
                id: id,
                currency: currency,
                darkMode: darkMode,
                privacyMode: privacyMode,
                shadowSavingsRate: shadowSavingsRate,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingData,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingData, BaseReferences<_$AppDatabase, $SettingsTable, SettingData>),
      SettingData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$WalletsTableTableManager get wallets =>
      $$WalletsTableTableManager(_db, _db.wallets);
  $$ShieldItemsTableTableManager get shieldItems =>
      $$ShieldItemsTableTableManager(_db, _db.shieldItems);
  $$DailySnapshotsTableTableManager get dailySnapshots =>
      $$DailySnapshotsTableTableManager(_db, _db.dailySnapshots);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
