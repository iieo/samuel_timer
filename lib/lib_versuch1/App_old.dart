import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './blocs/timer_bloc.dart';
import 'models/ticker.dart';
import '../background.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(80, 50, 250, 1),
        brightness: Brightness.dark,
      ),
      home: BlocProvider(
        create: (context) => TimerBloc(ticker: const Ticker()),
        child: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
            child: Stack(
          children: [
            Background(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${context.select((TimerBloc bloc) => bloc.state.duration)}',
                  style: Theme.of(context).textTheme.headline2,
                ),
                const ActionButtons(),

                /// show the name of the state for us better understanding
                Text(
                  '${context.select((TimerBloc bloc) => bloc.state)}',
                )
              ],
            ),
          ],
        )),
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  const ActionButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (state is TimerInitial) ...[
              FloatingActionButton(
                  child: const Icon(Icons.play_arrow),
                  onPressed: () =>
                      context.read<TimerBloc>().add(const TimerStarted())),
            ] else if (state is TimerRunInProgress) ...[
              FloatingActionButton(
                  child: const Icon(Icons.pause),
                  onPressed: () =>
                      context.read<TimerBloc>().add(const TimerPaused())),
              FloatingActionButton(
                  child: const Icon(Icons.refresh),
                  onPressed: () => context.read<TimerBloc>().add(TimerReset())),
            ] else if (state is TimerRunPause) ...[
              FloatingActionButton(
                  child: const Icon(Icons.play_arrow),
                  onPressed: () => context
                      .read<TimerBloc>()
                      .add(TimerResumed(state.duration))),
              FloatingActionButton(
                  child: const Icon(Icons.refresh),
                  onPressed: () => context.read<TimerBloc>().add(TimerReset())),
            ] else if (state is TimerRunComplete) ...[
              FloatingActionButton(
                  child: const Icon(Icons.refresh),
                  onPressed: () => context.read<TimerBloc>().add(TimerReset()))
            ],
          ],
        );
      },
    );
  }
}
