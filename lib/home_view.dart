import 'package:api_learning/char/char.dart';
import 'package:api_learning/get_charr_cubit/get_charr_cubit.dart';
import 'package:api_learning/get_charr_cubit/get_charr_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetCharrCubit(),
      child: const Scaffold(
        body: HomeListView(),
      ),
    );
  }
}

class HomeListView extends StatelessWidget {
  const HomeListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BlocConsumer<GetCharrCubit, GetCharrState>(
          listener: (context, state) {
            if (state is GetCharrError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message.toString()),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is GetCharrError) {
              return const SizedBox();
            } else if (state is GetCharrSuccess) {
              return Expanded(
                child: ListView.builder(
                  itemCount: state.charr.length,
                  itemBuilder: (context, index) {
                    return CharrCard(
                      character: state.charr[index],
                    );
                  },
                ),
              );
            } else if (state is GetCharrLoading) {
              return Expanded(
                child: Skeletonizer(
                  enabled: true,
                  child: ListView.builder(
                    itemCount: getDummyCharr().length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CharrCard(
                          character: getDummyCharr()[index],
                        ),
                      );
                    },
                  ),
                ),
              );
            } else {
              return const Center(child: Text('intial'));
            }
          },
        ),
        ElevatedButton(
          onPressed: () {
            context.read<GetCharrCubit>().getCharrList();
          },
          child: const Text('dvsd'),
        ),
      ],
    );
  }

  List<Charr> getDummyCharr() {
    return [
      Charr(name: "Hermione", image: "https://picsum.photos/200/300"),
      Charr(name: "Harry Potter", image: "https://picsum.photos/200/301"),
      Charr(name: "Ron Weasley", image: "https://picsum.photos/200/302"),
      Charr(name: "Dumbledore", image: "https://picsum.photos/200/303"),
      Charr(name: "Severus Snape", image: "https://picsum.photos/200/304"),
    ];
  }
}

class CharrCard extends StatelessWidget {
  final Charr character;
  const CharrCard({
    super.key,
    required this.character,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(character.name ?? ""),
      leading: Image.network(
        character.image ?? 'https://picsum.photos/200/300',
      ),
    );
  }
}
