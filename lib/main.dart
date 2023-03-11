import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'River pod example',
      theme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(),
    );
  }
}

enum City {
  stockhoms,
  paris,
  tokyo,
}

typedef WeatherEmoji = String;
Future<WeatherEmoji> getWeather(City city) {
  return Future.delayed(
      const Duration(seconds: 1),
      () => {
            City.stockhoms: '🌨️',
            City.paris: '⛈️',
            City.tokyo: '☀️',
          }[city]!);
}

const unKnownWeatherEmoji = '🤷‍♀️';
final currentCityProvider = StateProvider<City?>((ref) => null);
final weatherProvider = FutureProvider<WeatherEmoji>((ref) {
  final city = ref.watch(currentCityProvider);
  if (city != null) {
    return getWeather(city);
  } else {
    return unKnownWeatherEmoji;
  }
});

class MyHomePage extends ConsumerWidget {
  const MyHomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeather = ref.watch(weatherProvider);
    //currentWeather.when(data: )
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Riverpod examples'),
      ),
      body: Column(
        children: [
          currentWeather.when(
            data: (data) => Text(
              data,
              style: const TextStyle(fontSize: 40),
            ),
            error: (_, __) => const Text(
              '🥹',
              style: TextStyle(fontSize: 40),
            ),
            loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator()),
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: City.values.length,
                  itemBuilder: (context, index) {
                    final city = City.values[index];
                    final isSelected = city == ref.watch(currentCityProvider);
                    return ListTile(
                      title: Text(
                        city.toString(),
                      ),
                      trailing: isSelected ? const Icon(Icons.check) : null,
                      onTap: () {
                        ref.read(currentCityProvider.notifier).state = city;
                      },
                    );
                  }))
        ],
      ),
    );
  }
}
