import 'wand.dart';

class Charr {
  String? id;
  String? name;
  List<dynamic>? alternateNames;
  String? species;
  String? gender;
  String? house;
  String? dateOfBirth;
  int? yearOfBirth;
  bool? wizard;
  String? ancestry;
  String? eyeColour;
  String? hairColour;
  Wand? wand;
  String? patronus;
  bool? hogwartsStudent;
  bool? hogwartsStaff;
  String? actor;
  List<dynamic>? alternateActors;
  bool? alive;
  String? image;

  Charr({
    this.id,
    this.name,
    this.alternateNames,
    this.species,
    this.gender,
    this.house,
    this.dateOfBirth,
    this.yearOfBirth,
    this.wizard,
    this.ancestry,
    this.eyeColour,
    this.hairColour,
    this.wand,
    this.patronus,
    this.hogwartsStudent,
    this.hogwartsStaff,
    this.actor,
    this.alternateActors,
    this.alive,
    this.image,
  });

  factory Charr.fromJson(Map<String, dynamic> json) => Charr(
        id: json['id'] as String?,
        name: json['name'] as String?,
        alternateNames: json['alternate_names'] as List<dynamic>?,
        species: json['species'] as String?,
        gender: json['gender'] as String?,
        house: json['house'] as String?,
        dateOfBirth: json['dateOfBirth'] as String?,
        yearOfBirth: json['yearOfBirth'] as int?,
        wizard: json['wizard'] as bool?,
        ancestry: json['ancestry'] as String?,
        eyeColour: json['eyeColour'] as String?,
        hairColour: json['hairColour'] as String?,
        wand: json['wand'] == null
            ? null
            : Wand.fromJson(json['wand'] as Map<String, dynamic>),
        patronus: json['patronus'] as String?,
        hogwartsStudent: json['hogwartsStudent'] as bool?,
        hogwartsStaff: json['hogwartsStaff'] as bool?,
        actor: json['actor'] as String?,
        alternateActors: json['alternate_actors'] as List<dynamic>?,
        alive: json['alive'] as bool?,
        image: json['image'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'alternate_names': alternateNames,
        'species': species,
        'gender': gender,
        'house': house,
        'dateOfBirth': dateOfBirth,
        'yearOfBirth': yearOfBirth,
        'wizard': wizard,
        'ancestry': ancestry,
        'eyeColour': eyeColour,
        'hairColour': hairColour,
        'wand': wand?.toJson(),
        'patronus': patronus,
        'hogwartsStudent': hogwartsStudent,
        'hogwartsStaff': hogwartsStaff,
        'actor': actor,
        'alternate_actors': alternateActors,
        'alive': alive,
        'image': image,
      };
}
