part of 'transaction.dart';

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 0;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte() : reader.read()
    };

    return Transaction();
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer..writeByte(0);
  }

  @override
  int get hasCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => 
    identical(this, other) || other is TransactionAdapter && runtimeType
      == other.runtimeType && typeId == other.typeId;
}