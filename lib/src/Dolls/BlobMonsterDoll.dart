import 'package:RenderingLib/RendereringLib.dart';

import "../Dolls/Doll.dart";
import "../Dolls/HomestuckDoll.dart";
import "SpriteLayer.dart";
import "dart:typed_data";
import 'dart:convert';
import "../Rendering/ReferenceColors.dart";
import "Quirk.dart";




class BlobMonsterDoll extends Doll{

  @override
  String originalCreator = "jadedResearcher";

  @override
  int renderingType =25;

  @override
  int width = 100;
  @override
  int height = 100;

  @override
  String name = "BlobMonster";

  @override
  String relativefolder = "images/BlobMonster";
  final int maxBody = 7;
  final int maxHorn = 6;
  final int maxMouth = 4;
  final int maxWing = 8;
  final int maxEyes = 8;


  SpriteLayer body;
  SpriteLayer horns;
  SpriteLayer mouth;
  SpriteLayer eyes;
  SpriteLayer wings;

  @override
  List<SpriteLayer>  get renderingOrderLayers => <SpriteLayer>[body,eyes, mouth,horns,wings];
  @override
  List<SpriteLayer>  get dataOrderLayers => <SpriteLayer>[body,eyes, mouth,horns,wings];


  @override
  Palette palette = new BlobMonsterPalette();


  BlobMonsterDoll() {
    initLayers();
    initPalette();
    randomize();
  }

  void initPalette() {
    for(NCP ncp in BlobMonsterPalette.sourceColors) {
      ncp.addToPalette(paletteSource);
      ncp.addToPalette(palette);
    }
  }

  //HELL YES i found the source of the save bug.
  //i'm not supposed to use premade palettes like this, instead,
  //how does the drop downs work?
  @override
  void randomizeColors() {
    if (rand == null) rand = new Random();;
    List<Palette> paletteOptions = new List<Palette>.from(
        ReferenceColours.paletteList.values);
    Palette newPallete = rand.pickFrom(paletteOptions);
    if (rand.nextDouble() > 0.3) {
      tackyColors();
    } else {
      copyPalette(newPallete);
    }
  }


    void tackyColors() {
      BlobMonsterPalette o = palette as BlobMonsterPalette;

      palette.add(BlobMonsterPalette.SKIN, new Colour(rand.nextInt(255), rand.nextInt(255), rand.nextInt(255)),true);
      makeOtherColorsDarker(o, BlobMonsterPalette.SKIN, <String>[BlobMonsterPalette.SKINDARK]);

      palette.add(BlobMonsterPalette.ACCENT, new Colour(rand.nextInt(255), rand.nextInt(255), rand.nextInt(255)),true);
      makeOtherColorsDarker(o, BlobMonsterPalette.ACCENT, <String>[BlobMonsterPalette.ACCENTDARK]);

      palette.add(BlobMonsterPalette.FEATHER1, new Colour(rand.nextInt(255), rand.nextInt(255), rand.nextInt(255)),true);
      makeOtherColorsDarker(o, BlobMonsterPalette.FEATHER1, <String>[BlobMonsterPalette.FEATHER1DARK]);

      palette.add(BlobMonsterPalette.FEATHER2, new Colour(rand.nextInt(255), rand.nextInt(255), rand.nextInt(255)),true);
      makeOtherColorsDarker(o, BlobMonsterPalette.FEATHER2, <String>[BlobMonsterPalette.FEATHER2DARK]);

      palette.add(BlobMonsterPalette.EYES, new Colour(rand.nextInt(255), rand.nextInt(255), rand.nextInt(255)),true);
      makeOtherColorsDarker(o, BlobMonsterPalette.EYES, <String>[BlobMonsterPalette.EYESDARK]);

    }

  @override
  void randomizeNotColors() {
    for(SpriteLayer l in renderingOrderLayers) {
      l.imgNumber = rand.nextInt(l.maxImageNumber+1);
    }
  }

  @override
  void load(String dataString) {
    Uint8List thingy = BASE64URL.decode(dataString);
    ByteReader reader = new ByteReader(thingy.buffer, 0);
    int type = reader.readByte(); //not gonna use, but needs to be gone for reader
    initFromReader(reader, new HomestuckPalette(), false);
  }

  BlobMonsterDoll.fromDataString(String dataString){
    Uint8List thingy = BASE64URL.decode(dataString);
    ByteReader reader = new ByteReader(thingy.buffer, 0);
    int type = reader.readByte(); //not gonna use, but needs to be gone for reader
    print("Initing a blob Doll From Reader $dataOrderLayers");
    initFromReader(reader, new BlobMonsterPalette());
  }

  //assumes type byte is already gone
  BlobMonsterDoll.fromReader(ByteReader reader){
    initFromReader(reader,new BlobMonsterPalette());
  }

  @override
  void setQuirk() {
    Random rand  = new Random(seed);
    quirkButDontUse = Quirk.randomHumanQuirk(rand);
  }

  @override
  void initLayers() {
    {
      //leftHeadFur, leftEar, rightEar, snout, accessory, backLegs, frontLegs];
      body = new SpriteLayer("Body","$folder/bodies/", 1, maxBody);
      horns = new SpriteLayer("Horns","$folder/horns/", 1, maxHorn);
      mouth = new SpriteLayer("Mouth","$folder/mouths/", 1, maxMouth);
      eyes = new SpriteLayer("Eyes","$folder/eyes/", 1, maxEyes);
      wings = new SpriteLayer("Limb","$folder/wings/", 1, maxWing);

    }
  }

}



class BlobMonsterPalette extends Palette {
  static String EYES = "eyes"; //yellow
  static String EYESDARK = "eyesDark"; //yellow
  static String SKIN = "skin"; //green
  static String SKINDARK = "skinDark"; //green
  static String FEATHER1 = "feather1"; //red
  static String FEATHER1DARK = "feather1Dark"; //red
  static String FEATHER2 = "feather2"; //blue
  static String FEATHER2DARK = "feather2Dark"; //blue
  static String ACCENT = "accent"; //
  static String ACCENTDARK = "accentDark"; //purple

  static List<NCP> sourceColors = <NCP>[new NCP(ACCENT,"#b400ff"), new NCP(ACCENTDARK,"#6f009e"),new NCP(SKIN,"#00ff20"), new NCP(SKINDARK,"#06ab1b"),new NCP(FEATHER1,"#ff0000"), new NCP(FEATHER1DARK,"#ae0000"),new NCP(FEATHER2,"#0135ff"), new NCP(FEATHER2,"#011f93"),new NCP(EYES,"#f6ff00"), new NCP(EYESDARK,"#bdc400")];

  static Colour _handleInput(Object input) {
    if (input is Colour) {
      return input;
    }
    if (input is int) {
      return new Colour.fromHex(input, input
          .toRadixString(16)
          .padLeft(6, "0")
          .length > 6);
    }
    if (input is String) {
      if (input.startsWith("#")) {
        return new Colour.fromStyleString(input);
      } else {
        return new Colour.fromHexString(input);
      }
    }
    throw "Invalid AspectPalette input: colour must be a Colour object, a valid colour int, or valid hex string (with or without leading #)";
  }




}