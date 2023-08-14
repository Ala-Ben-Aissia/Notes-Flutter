// Default code but using Bloc not setState (counter incremented by 1)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Test'),
        ),
        body: BlocConsumer<CounterBloc, CounterState>(
          listener: (context, state) {},
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'The button has been clicked ${state.counter} times',
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        context.read<CounterBloc>().add(
                              IncrementCounterEvent(
                                state.counter,
                              ),
                            );
                      },
                      child: const Icon(Icons.add),
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        context.read<CounterBloc>().add(
                              ResetCounterEvent(
                                state.counter,
                              ),
                            );
                      },
                      child: const Icon(
                        Icons.restore,
                      ),
                    )
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class CounterState {
  final int counter;
  const CounterState(this.counter);
}

abstract class CounterEvent {
  final int counter;
  const CounterEvent(this.counter);
}

class IncrementCounterEvent extends CounterEvent {
  IncrementCounterEvent(super.counter);
}

class ResetCounterEvent extends CounterEvent {
  ResetCounterEvent(super.counter);
}

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterState(0)) {
    on<IncrementCounterEvent>(
      (event, emit) => emit(
        CounterState(state.counter + 1),
      ),
    );
    on<ResetCounterEvent>(
      (event, emit) => emit(
        const CounterState(0),
      ),
    );
  }
}
