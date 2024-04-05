abstract class RecieptState {}

class RecieptOpened extends RecieptState {}

class RecieptLoading extends RecieptState {}

class RecieptClosed extends RecieptState {}

class RecieptPrinted extends RecieptState{}

class RecieptError extends RecieptState {}

class RecieptInitial extends RecieptState{}
