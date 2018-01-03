import "../Misc/random.dart";
import "../includes/colour.dart";
import "../Dolls/Doll.dart";
import "SpriteLayer.dart";
import "dart:typed_data";
import 'dart:convert';
import "../includes/bytebuilder.dart";
import "../includes/palette.dart";
import "../Rendering/ReferenceColors.dart";
import "HomestuckDoll.dart";

//MadCreativity championed this one.
class HiveswapDoll extends Doll {
    int maxBody = 1;
    int maxEyebrows = 3;
    int maxHorn = 8;
    int maxHair = 8;
    int maxFin = 1;

    int maxEyes = 3;
    int maxMouth =11;



    String folder = "images/Homestuck/Hiveswap";

    SpriteLayer body;
    SpriteLayer eyebrows;
    SpriteLayer leftEye;
    SpriteLayer rightEye;
    SpriteLayer hairTop;
    SpriteLayer hairBack;
    SpriteLayer leftHorn;
    SpriteLayer rightHorn;
    SpriteLayer mouth;
    SpriteLayer leftFin;
    SpriteLayer rightFin;



    @override
    List<SpriteLayer>  get renderingOrderLayers => <SpriteLayer>[body,hairBack,rightFin, eyebrows,leftEye,rightEye, hairTop,leftHorn, rightHorn,mouth,leftFin];
    @override
    List<SpriteLayer>  get dataOrderLayers => <SpriteLayer>[body,eyebrows,leftEye, rightEye,hairBack,hairTop,leftHorn, rightHorn,mouth,leftFin,rightFin];


    @override
    int width = 900;
    @override
    int height = 1000;

    @override
    int renderingType =14; //hiveswap release date is 9/14

    @override
    Palette paletteSource = new HiveswapTrollPalette()
        ..skin = '#C947FF'
        ..eye_white_left = '#5D52DE'
        ..eye_white_right = '#D4DE52'
        ..accent = "#9130BA"
        ..shirt_dark = "#3957C8"
        ..pants_light = "#6C47FF"
        ..pants_dark = "#87FF52"
        ..shoe_light = "#5CDAFF"
        ..hair_main = "#5FDE52"
        ..shirt_light = '#3358FF';

    @override
    Palette palette = new HiveswapTrollPalette()
        ..accent = '#FF9B00'
        ..aspect_light = '#FF9B00'
        ..aspect_dark = '#FF8700'
        ..shoe_light = '#111111'
        ..shoe_dark = '#333333'
        ..cloak_light = '#A3A3A3'
        ..cloak_mid = '#999999'
        ..cloak_dark = '#898989'
        ..shirt_light = '#151515'
        ..shirt_dark = '#000000'
        ..pants_light = '#4b4b4b'
        ..eye_white_left = '#ffba29'
        ..eye_white_right = '#ffba29'
        ..pants_dark = '#3a3a3a'
        ..hair_accent = '#aa0000'
        ..hair_main = '#151515'
        ..skin = '#C4C4C4';

    HiveswapDoll() {
        initLayers();
        randomize();
    }

    HiveswapDoll.fromDataString(String dataString){
        Uint8List thingy = BASE64URL.decode(dataString);
        ByteReader reader = new ByteReader(thingy.buffer, 0);
        int type = reader.readByte(); //not gonna use, but needs to be gone for reader
        initFromReader(reader, new HiveswapTrollPalette());
    }

    @override
    void load(String dataString) {
        Uint8List thingy = BASE64URL.decode(dataString);
        ByteReader reader = new ByteReader(thingy.buffer, 0);
        int type = reader.readByte(); //not gonna use, but needs to be gone for reader
        initFromReader(reader, new HiveswapTrollPalette(), false);
    }

    //assumes type byte is already gone
    HiveswapDoll.fromReader(ByteReader reader){
        initFromReader(reader,new HiveswapTrollPalette());
    }


    String chooseBlood(Random rand) {
        List<String> bloodColors = <String>["#A10000", "#a25203", "#a1a100", "#658200", "#416600", "#078446", "#008282", "#004182", "#0021cb", "#631db4", "#610061", "#99004d"];
        String chosenBlood = rand.pickFrom(bloodColors);
        return chosenBlood;
    }

    @override
    void randomize([bool chooseSign = true]) {
        Random rand = new Random();
        int firstEye = -100;
        int firstHorn = -100;

        //canonSymbol.imgNumber = maxCanonSymbol;

        String chosenBlood = chooseBlood(rand);
        for (SpriteLayer l in renderingOrderLayers) {
                //don't have wings normally
                if (!l.imgNameBase.contains("Wings")) l.imgNumber = rand.nextInt(l.maxImageNumber + 1);
                //keep eyes synced unless player decides otherwise
                if (l.imgNameBase.contains("Eye")) {
                    if (firstEye < 0) {
                        firstEye = l.imgNumber;
                    } else {
                        l.imgNumber = firstEye;
                    }
                }

                if (l.imgNameBase.contains("Horn")) {
                    if (firstHorn < 0) {
                        firstHorn = l.imgNumber;
                    } else {
                        l.imgNumber = firstHorn;
                    }
                }

                avoidBlank();
                if (l.imgNameBase.contains("Fin")) {
                    //"#610061", "#99004d"
                    if (chosenBlood == "#610061" || chosenBlood == "#99004d") {
                        l.imgNumber = 1;
                    } else {
                        l.imgNumber = 0;
                    }
                }
                if (l.imgNameBase.contains("Glasses") && rand.nextDouble() > 0.35) l.imgNumber = 0;
        }

        HiveswapTrollPalette h = palette as HiveswapTrollPalette;
        palette.add(HiveswapTrollPalette._ACCENT, new Colour.fromStyleString("#969696"), true);
        palette.add(HiveswapTrollPalette._ASPECT_LIGHT, new Colour.fromStyleString(chosenBlood), true);

        palette.add(HiveswapTrollPalette._ASPECT_DARK, new Colour(h.aspect_light.red, h.aspect_light.green, h.aspect_light.blue)..setHSV(h.aspect_light.hue, h.aspect_light.saturation, h.aspect_light.value/2), true);
        // palette.add(HomestuckTrollPalette._SHOE_LIGHT, new Colour(rand.nextInt(255), rand.nextInt(255), rand.nextInt(255)), true);
        // palette.add(HomestuckTrollPalette._SHOE_DARK, new Colour(h.shoe_light.red, h.shoe_light.green, h.shoe_light.blue)..setHSV(h.shoe_light.hue, h.shoe_light.saturation, h.shoe_light.value/2), true);
        palette.add(HiveswapTrollPalette._CLOAK_LIGHT, new Colour.from(h.aspect_light), true);
        palette.add(HiveswapTrollPalette._CLOAK_DARK, new Colour.from(h.aspect_dark),true);
        palette.add(HiveswapTrollPalette._CLOAK_MID, new Colour(h.cloak_dark.red, h.cloak_dark.green, h.cloak_dark.blue)..setHSV(h.cloak_dark.hue, h.cloak_dark.saturation, h.cloak_dark.value*3), true);
        palette.add(HiveswapTrollPalette._WING1, new Colour.fromStyleString(chosenBlood), true);
        palette.add(HiveswapTrollPalette._WING2, new Colour(h.wing1.red, h.wing1.green, h.wing1.blue)..setHSV(h.wing1.hue, h.wing1.saturation, h.wing1.value/2), true);
        palette.add(HiveswapTrollPalette._HAIR_ACCENT, new Colour(h.wing1.red, h.wing1.green, h.wing1.blue), true);
    }

    void avoidBlank() {
        if(mouth.imgNumber == 0) mouth.imgNumber = 1;
        if(leftEye.imgNumber == 0) leftEye.imgNumber = 1;
        if(leftHorn.imgNumber == 0) leftHorn.imgNumber = 1;
        if(rightEye.imgNumber == 0) rightEye.imgNumber = 1;
        if(rightHorn.imgNumber == 0) rightHorn.imgNumber = 1;
    }


    @override
    void randomizeNotColors() {
        Random rand = new Random();
        int firstEye = -100;
        int firstHorn = -100;
        List<String> bloodColors = <String>["#A10000", "#a25203", "#a1a100", "#658200", "#416600", "#078446", "#008282", "#004182", "#0021cb", "#631db4", "#610061", "#99004d"];

        String chosenBlood = rand.pickFrom(bloodColors);
        for (SpriteLayer l in renderingOrderLayers) {
            //don't have wings normally
            if (!l.imgNameBase.contains("Wings")) l.imgNumber = rand.nextInt(l.maxImageNumber + 1);
            //keep eyes synced unless player decides otherwise
            if (l.imgNameBase.contains("Eye")) {
                if (firstEye < 0) {
                    firstEye = l.imgNumber;
                } else {
                    l.imgNumber = firstEye;
                }
            }

            if (l.imgNameBase.contains("Horn")) {
                if (firstHorn < 0) {
                    firstHorn = l.imgNumber;
                } else {
                    l.imgNumber = firstHorn;
                }
            }

            avoidBlank();
            if (l.imgNameBase.contains("Fin")) {
                //"#610061", "#99004d"
                if (chosenBlood == "#610061" || chosenBlood == "#99004d") {
                    l.imgNumber = 1;
                } else {
                    l.imgNumber = 0;
                }
            }
            if (l.imgNameBase.contains("Glasses") && rand.nextDouble() > 0.35) l.imgNumber = 0;
        }

    }

    @override
    void randomizeColors() {
        Random rand = new Random();
        List<String> bloodColors = <String>["#A10000", "#a25203", "#a1a100", "#658200", "#416600", "#078446", "#008282", "#004182", "#0021cb", "#631db4", "#610061", "#99004d"];

        String chosenBlood = rand.pickFrom(bloodColors);
        HiveswapTrollPalette h = palette as HiveswapTrollPalette;


        palette.add(HiveswapTrollPalette._ACCENT, new Colour.fromStyleString("#969696"), true);
        palette.add(HiveswapTrollPalette._ASPECT_LIGHT, new Colour.fromStyleString(chosenBlood), true);

        palette.add(HiveswapTrollPalette._ASPECT_DARK, new Colour(h.aspect_light.red, h.aspect_light.green, h.aspect_light.blue)..setHSV(h.aspect_light.hue, h.aspect_light.saturation, h.aspect_light.value / 2), true);
        palette.add(HiveswapTrollPalette._SHOE_LIGHT, new Colour(rand.nextInt(255), rand.nextInt(255), rand.nextInt(255)), true);
        palette.add(HiveswapTrollPalette._SHOE_DARK, new Colour(h.shoe_light.red, h.shoe_light.green, h.shoe_light.blue)..setHSV(h.shoe_light.hue, h.shoe_light.saturation, h.shoe_light.value / 2), true);
        palette.add(HiveswapTrollPalette._CLOAK_LIGHT, new Colour(rand.nextInt(255), rand.nextInt(255), rand.nextInt(255)), true);
        palette.add(HiveswapTrollPalette._CLOAK_DARK, new Colour(h.cloak_light.red, h.cloak_light.green, h.cloak_light.blue)..setHSV(h.cloak_light.hue, h.cloak_light.saturation, h.cloak_light.value / 2), true);
        palette.add(HiveswapTrollPalette._CLOAK_MID, new Colour(h.cloak_dark.red, h.cloak_dark.green, h.cloak_dark.blue)..setHSV(h.cloak_dark.hue, h.cloak_dark.saturation, h.cloak_dark.value * 3), true);
        palette.add(HiveswapTrollPalette._PANTS_LIGHT, new Colour(rand.nextInt(255), rand.nextInt(255), rand.nextInt(255)), true);
        palette.add(HiveswapTrollPalette._PANTS_DARK, new Colour(h.pants_light.red, h.pants_light.green, h.pants_light.blue)..setHSV(h.pants_light.hue, h.pants_light.saturation, h.pants_light.value / 2), true);
        palette.add(HiveswapTrollPalette._WING1, new Colour.fromStyleString(chosenBlood), true);
        palette.add(HiveswapTrollPalette._WING2, new Colour(h.wing1.red, h.wing1.green, h.wing1.blue)..setHSV(h.wing1.hue, h.wing1.saturation, h.wing1.value / 2), true);
        palette.add(HiveswapTrollPalette._HAIR_ACCENT, new Colour(h.wing1.red, h.wing1.green, h.wing1.blue), true);
    }


    @override
    void initLayers() {
        hairTop = new SpriteLayer("Hair","$folder/HairTop/", 1, maxHair);
        hairBack = new SpriteLayer("Hair","$folder/HairBack/", 1, maxHair, syncedWith:<SpriteLayer>[hairTop]);
        hairTop.syncedWith.add(hairBack);
        hairBack.slave = true; //can't be selected on it's own

        leftFin = new SpriteLayer("Fin", "$folder/LeftFin/", 1, maxFin);
        rightFin = new SpriteLayer("Fin", "$folder/RightFin/", 1, maxFin, syncedWith: <SpriteLayer>[leftFin]);
        leftFin.syncedWith.add(rightFin);
        rightFin.slave = true; //can't be selected on it's own

        body = new SpriteLayer("Body", "$folder/Body/", 1, maxBody);


        eyebrows = new SpriteLayer("EyeBrows", "$folder/Eyebrows/", 1, maxEyebrows);
        leftEye = new SpriteLayer("LeftEye", "$folder/LeftEye/", 1, maxEyes);
        rightEye = new SpriteLayer("RightEye", "$folder/RightEye/", 1, maxEyes);
        leftHorn = new SpriteLayer("LeftHorn", "$folder/LeftHorn/", 1, maxHorn);
        rightHorn = new SpriteLayer("RightHorn", "$folder/RightHorn/", 1, maxHorn);
        mouth = new SpriteLayer("Mouth", "$folder/Mouth/", 1, maxMouth);
    }

}




/// Convenience class for getting/setting aspect palettes
class HiveswapTrollPalette extends HomestuckPalette {
    static String _ACCENT = "accent";
    static String _ASPECT_LIGHT = "aspect1";
    static String _ASPECT_DARK = "aspect2";
    static String _SHOE_LIGHT = "shoe1";
    static String _SHOE_DARK = "shoe2";
    static String _CLOAK_LIGHT = "cloak1";
    static String _CLOAK_MID = "cloak2";
    static String _CLOAK_DARK = "cloak3";
    static String _SHIRT_LIGHT = "shirt1";
    static String _SHIRT_DARK = "shirt2";
    static String _PANTS_LIGHT = "pants1";
    static String _PANTS_DARK = "pants2";
    static String _WING1 = "wing1";
    static String _WING2 = "wing2";
    static String _HAIR_MAIN = "hairMain";
    static String _HAIR_ACCENT = "hairAccent";
    static String _EYE_WHITES = "eyeWhites";
    static String _SKIN = "skin";

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

    Colour get wing1 => this[_WING1];

    void set wing1(dynamic c) => this.add(_WING1, _handleInput(c), true);

    Colour get wing2 => this[_WING2];

    void set wing2(dynamic c) => this.add(_WING2, _handleInput(c), true);
}

