part of 'remind_cubit.dart';

class RemindState extends Equatable {
  final bool isEnabled;

  const RemindState({required this.isEnabled});

  const RemindState.initial() : this(isEnabled: false);

  RemindState copyWith({bool? isEnabled}) {
    return RemindState(isEnabled: isEnabled ?? this.isEnabled);
  }

  @override
  List<Object> get props => [isEnabled];
}
