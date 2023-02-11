import 'dart:async';

import 'package:TrackYourStop/utils/transportation_type.util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_image_stack/flutter_image_stack.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:TrackYourStop/modules/favorites/provider/polled_departures_provider.dart';
import 'package:TrackYourStop/modules/favorites/provider/selected_destinations_provider.dart';
import 'package:TrackYourStop/modules/favorites/provider/selected_origin_provider.dart';
import 'package:TrackYourStop/modules/favorites/provider/selected_transportation_types_provider.dart';
import 'package:TrackYourStop/modules/favorites/provider/station_controller_provider.dart';
import 'package:TrackYourStop/modules/favorites/ui/favorite_app_bar.dart';
import 'package:TrackYourStop/outbound/interactor/mvg_interactor.dart';
import 'package:TrackYourStop/outbound/models/departure_response.dart';
import 'package:TrackYourStop/outbound/models/station_response.dart';
import 'package:TrackYourStop/utils/logger.dart';

final logger = getLogger("FavoritePage");

class FavoritePage extends HookConsumerWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Add/Remove departure response to state
    void onDestinationSelected(bool selected, DepartureResponse departure) {
      if (selected == true) {
        ref
            .read(selectedDestinationsProvider.notifier)
            .addDestination(departure);
      } else {
        ref
            .read(selectedDestinationsProvider.notifier)
            .removeDestination(departure);
      }
    }

    // Save selected chips to state
    Widget buildChips() {
      List<Widget> chips = [];
      final List<String> selectedTransportationTypes =
          ref.watch(selectedTransportationTypesProvider);
      for (var transportType in selectedTransportationTypes) {
        InputChip actionChip = InputChip(
          label: Text(""),
          avatar: Container(
              width: 35.0,
              height: 17.0,
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: ExactAssetImage(getAssetForTransportationType(
                          transportType.toUpperCase()))))),
          deleteIcon: const Icon(Icons.remove_circle),
          onDeleted: () {
            ref
                .read(selectedTransportationTypesProvider.notifier)
                .removeTransportationType(transportType);
            ref.read(polledDeparturesProvider.notifier).state =
                MvgInteractor.fetchDeparturesByOriginAndTransportTypes(
                    ref.watch(selectedOriginProvider),
                    ref.watch(selectedTransportationTypesProvider));
          },
        );
        chips.add(actionChip);
      }
      return ListView.builder(
          // This next line does the trick.
          scrollDirection: Axis.horizontal,
          itemCount: chips.length,
          itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: 5.0), child: chips[index]));
    }

    Widget buildBody() {
      TextEditingController transportationTypeController =
          TextEditingController();

      return Padding(
        padding: const EdgeInsets.only(top: 30.0, left: 32.0, right: 32.0),
        child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                // Station selection autocomplete field
                Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: TypeAheadField<StationResponse?>(
                      noItemsFoundBuilder: (context) => const SizedBox(
                          height: 50.0,
                          child: Center(
                              child:
                                  Text('No station found for provided name.'))),
                      hideSuggestionsOnKeyboardHide: false,
                      hideKeyboardOnDrag: true,
                      debounceDuration: const Duration(milliseconds: 1000),
                      suggestionsCallback: MvgInteractor.getStationSuggestions,
                      itemBuilder: (context, StationResponse? suggestion) {
                        final stationResponse = suggestion!;
                        final List<ImageProvider> transportationTypeAssets =
                            getAssetListForTransportationType(
                                stationResponse.transportTypes);
                        return ListTile(
                            title: Text(stationResponse.name),
                            leading: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minWidth: 10,
                                  maxWidth: 50,
                                  minHeight: 20,
                                  maxHeight: 100,
                                ),
                                child: FlutterImageStack.providers(
                                  providers: transportationTypeAssets,
                                  totalCount: transportationTypeAssets.length,
                                  itemCount: transportationTypeAssets.length,
                                  itemBorderWidth: 1,
                                )));
                      },
                      textFieldConfiguration: TextFieldConfiguration(
                          controller: ref.watch(stationControllerProvider),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search),
                            labelText: 'Name of the origin station',
                          )),
                      onSuggestionSelected: (StationResponse? selection) {
                        logger.d('Selected station: ${selection!.toJson()}');
                        ref.read(selectedOriginProvider.notifier).state =
                            selection;
                        ref.watch(stationControllerProvider).text =
                            selection.name;
                        ref.read(polledDeparturesProvider.notifier).state =
                            MvgInteractor
                                .fetchDeparturesByOriginAndTransportTypes(
                                    ref.watch(selectedOriginProvider),
                                    TransportationTypeEnum.values
                                        .map((e) => e.name)
                                        .toList());
                      },
                    )),
                // Transportation type filter autocomplete field
                Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: TypeAheadField<String>(
                        noItemsFoundBuilder: (context) => const SizedBox(
                            height: 50.0,
                            child: Center(
                                child: Text('No transport types found yet.'))),
                        hideSuggestionsOnKeyboardHide: false,
                        hideKeyboardOnDrag: true,
                        suggestionsCallback: (input) {
                          final selectedStation =
                              ref.watch(selectedOriginProvider);
                          if (input == '') {
                            return selectedStation == null
                                ? const Iterable<String>.empty()
                                : selectedStation.transportTypes;
                          }

                          return selectedStation!.transportTypes
                              .map((e) => e.toUpperCase())
                              .where((option) =>
                                  option.contains(input.toUpperCase()));
                        },
                        onSuggestionSelected: (selection) {
                          ref
                              .read(
                                  selectedTransportationTypesProvider.notifier)
                              .addTransportationType(selection);
                          ref.watch(stationControllerProvider).text =
                              ref.watch(selectedOriginProvider)!.name;
                          ref.read(polledDeparturesProvider.notifier).state =
                              MvgInteractor
                                  .fetchDeparturesByOriginAndTransportTypes(
                                      ref.watch(selectedOriginProvider),
                                      ref.watch(
                                          selectedTransportationTypesProvider));
                        },
                        itemBuilder: (context, String suggestion) {
                          return ListTile(
                              title: Image.asset(
                                  getAssetForTransportationType(suggestion),
                                  height: 20,
                                  width: 10));
                        },
                        textFieldConfiguration: TextFieldConfiguration(
                            controller: transportationTypeController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.train),
                              labelText: 'Filter for type of transportation',
                            )))),
                // Chip list containing selected transportation types
                Container(
                    height: 50.0,
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: buildChips()),
                // Destination divider
                const Divider(
                  indent: 10.0,
                  endIndent: 10.0,
                  thickness: 2,
                ),
                Align(
                  alignment: AlignmentDirectional.center,
                  child: Text(
                    'Select preferred destinations:',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.start,
                  ),
                ),
                // Future list view for destinations according to selected origin and transportation types
                Expanded(
                    child: FutureBuilder(
                        future: ref.watch(polledDeparturesProvider),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                            case ConnectionState.waiting:
                              return const Center(
                                  child: CircularProgressIndicator());
                            default:
                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else {
                                final List<DepartureResponse> departures =
                                    snapshot.data;
                                logger.i(departures.length);
                                return ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    primary: true,
                                    shrinkWrap: true,
                                    itemCount: departures.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final List<DepartureResponse>
                                          selectedDestinations = ref.watch(
                                              selectedDestinationsProvider);
                                      return CheckboxListTile(
                                          value: selectedDestinations
                                              .contains(departures[index]),
                                          onChanged: (bool? selected) {
                                            onDestinationSelected(
                                                selected!, departures[index]);
                                          },
                                          title: Text(
                                              departures[index].destination),
                                          secondary: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                minWidth: 10,
                                                maxWidth: 50,
                                                minHeight: 20,
                                                maxHeight: 100,
                                              ),
                                              child: Image.asset(
                                                  getAssetForTransportationType(
                                                      departures[index]
                                                          .transportType))));
                                    });
                              }
                          }
                        }))
              ],
            )),
      );
    }

    return Scaffold(
      extendBody: true,
      appBar: FavoriteAppBar(),
      body: buildBody(),
    );
  }
}
