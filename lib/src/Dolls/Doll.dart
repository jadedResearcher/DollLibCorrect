import "SpriteLayer.dart";
import "dart:typed_data";
import "dart:html";
import 'dart:convert';
import 'dart:async';

import "../../DollRenderer.dart";

import 'package:RenderingLib/src/Misc/weighted_lists.dart';
import 'package:RenderingLib/src/includes/bytebuilder.dart'as OldByteBuilder;
abstract class Doll {
    static String labelPattern = ":___";
    //whatever calls me is responsible for deciding if it wants to be url encoded or not
    String get label => "$dollName$labelPattern";

    //useful for the builder
    static List<int> allDollTypes = <int>[1,2,16,12,13,3,4,7,9,10,14,113,15,8,151,17,18,19,20,41,42,22,23,25,27,21];

    static List<Doll> _allDollsEvenWIPS = new List<Doll>();
    static Map<int, Doll> _allDollsMappedByType = new Map<int, Doll>();

    static Map<int, Doll> get  allDollsMappedByType {
        if(_allDollsMappedByType.isEmpty) {
            for(Doll doll in allDollsEvenWIPS) {
                _allDollsMappedByType[doll.renderingType]= doll;
            }
        }
        return _allDollsMappedByType;
    }
    static List<Doll> get allDollsEvenWIPS {
        if(_allDollsEvenWIPS.isEmpty) {
            _allDollsEvenWIPS.add(new AncestorDoll());
            _allDollsEvenWIPS.add(new BlobMonsterDoll());
            _allDollsEvenWIPS.add(new BroDoll());
            _allDollsEvenWIPS.add(new BroomDoll());
            _allDollsEvenWIPS.add(new CatDoll());
            _allDollsEvenWIPS.add(new ConsortDoll());
            _allDollsEvenWIPS.add(new DadDoll());
            _allDollsEvenWIPS.add(new DenizenDoll());
            _allDollsEvenWIPS.add(new DocDoll());
            _allDollsEvenWIPS.add(new DogDoll());
            _allDollsEvenWIPS.add(new EasterEggDoll());
            _allDollsEvenWIPS.add(new EggDoll());
            _allDollsEvenWIPS.add(new HatchedChick());
            _allDollsEvenWIPS.add(new HiveswapDoll());
            _allDollsEvenWIPS.add(new HomestuckBabyDoll());
            _allDollsEvenWIPS.add(new HomestuckCherubDoll());
            _allDollsEvenWIPS.add(new HomestuckDoll());
            _allDollsEvenWIPS.add(new HomestuckGrubDoll());
            _allDollsEvenWIPS.add(new HomestuckHeroDoll());
            _allDollsEvenWIPS.add(new HomestuckSatyrDoll());
            _allDollsEvenWIPS.add(new HomestuckTrollDoll());
            _allDollsEvenWIPS.add(new MomDoll());
            _allDollsEvenWIPS.add(new MonsterPocketDoll());
            _allDollsEvenWIPS.add(new OpenBoundDoll());
            _allDollsEvenWIPS.add(new PigeonDoll());
            _allDollsEvenWIPS.add(new PupperDoll());
            _allDollsEvenWIPS.add(new QueenDoll());
            _allDollsEvenWIPS.add(new SuperbSuckDoll());
            _allDollsEvenWIPS.add(new TalkSpriteDoll());
            _allDollsEvenWIPS.add(new TrollEggDoll());
            _allDollsEvenWIPS.add(new VirusDoll());
        }
        return _allDollsEvenWIPS;
    }

    String originalCreator = "???";

    //in case i want controlled random
    Random rand = new Random();

    Quirk quirkButDontUse;

    String name = "Unknown";
    //used for labeling and things like rom sim
    String dollName = "";

    //things can optionally cause the doll's orientation to change, like grub body 7 and 8
    static String NORMALWAYS = "normalways"; //flipped horizontal
    //is this not working? turnways is fighting me
    static String TURNWAYS = "turnways"; //flipped horizontal
    static String TURNWAYSBUTUP = "turnwaysFlipped"; //flipped horizontal and vertical
    static String UPWAYS = "upways"; //flipped vertical

    bool useAbsolutePath = true;

    int get seed {
        int s = associatedColor.red + associatedColor.green + associatedColor.blue;
        for(SpriteLayer imageLayer in renderingOrderLayers) {
            s += imageLayer.imgNumber;
        }
        return s;
    }

    Quirk get quirk {
        if(quirkButDontUse == null) {
            setQuirk();
        }
        return quirkButDontUse;
    }


    String relativefolder;
    String absolutePathStart = "/DollSource/";

    String get folder {
        if(useAbsolutePath) {
            return "$absolutePathStart$relativefolder";
        }else {
            return relativefolder;
        }
    }


    String orientation = NORMALWAYS;
    Colour _associatedColor;
    int width;
    int height;
    int renderingType = 0;
    static String localStorageKey = "doll";

    List<Palette> get validPalettes => <Palette>[];
    Map<String, Palette> get validPalettesMap =>new  Map<String, Palette>();


    //IMPORTANT  if i want save strings to not break if new rendering order, then rendering order and load order must be different things.

    ///in rendering order.
    List<SpriteLayer>  get renderingOrderLayers => new List<SpriteLayer>();
    //what order do we save load these. things humans have first, then trolls, then new layers so you don't break save data strings
    List<SpriteLayer>  get dataOrderLayers => new List<SpriteLayer>();
    List<SpriteLayer>  get oldDataLayers => new List<SpriteLayer>();

    Palette palette;

    Palette paletteSource = ReferenceColours.SPRITE_PALETTE;

    Colour get associatedColor {
        if(_associatedColor == null) {
            if(palette is HomestuckPalette || palette is HomestuckTrollPalette) {
                _associatedColor = (palette as HomestuckPalette).aspect_light;
            }else {
                _associatedColor = palette.first;
            }
        }
        return _associatedColor;
    }

    Doll() {
        if(window.location.hostname.contains("localhost")) {
            useAbsolutePath = false;
             //absolutePathStart = "http://www.farragofiction.com/DollSource/";
        }

    }

    //does nothing by default
    void setUpWays() {

    }


    void initLayers();
    void randomize() {
        randomizeColors();
        randomizeNotColors();
    }


    static Doll convertOneDollToAnother(Doll source, Doll replacement) {
        if(source is HomestuckDoll && replacement is HomestuckDoll) {
            HomestuckDoll r = replacement as HomestuckDoll;
            HomestuckDoll s = source as HomestuckDoll;
            //print("before replacement source hair is ${s.extendedHairBack.imgNumber} and replacement hair is ${r.extendedHairBack.imgNumber}");
        }
        for(SpriteLayer sourceLayer in source.dataOrderLayers) {
            for(SpriteLayer replacementLayer in replacement.dataOrderLayers) {
                //don't compare imgNameBase since it'll be diff on local vs remote apparently
                if(sourceLayer.name == replacementLayer.name) {
                    //print("${sourceLayer.imgNameBase} is ${replacementLayer.imgNameBase}");
                    //even if similar doll typesp might have different maxes
                    replacementLayer.imgNumber = sourceLayer.imgNumber % (replacementLayer.maxImageNumber+1);
                }else {
                    //print("${sourceLayer.imgNameBase} is not ${replacementLayer.imgNameBase}");
                }
            }
        }
        List<String> keysToReplace = new List<String>();

        for(String sourceName in source.palette.names) {
            for (String replacementName in replacement.palette.names) {
                if (sourceName == replacementName) {
                    keysToReplace.add(sourceName);
                }
            }
        }

        for(String key in keysToReplace) {
            replacement.palette.add(key, source.palette[key], true);
        }

        if(source is HomestuckDoll && replacement is HomestuckDoll) {
            HomestuckDoll r = replacement as HomestuckDoll;
            HomestuckDoll s = source as HomestuckDoll;
            //print("after replacement source hair is ${s.extendedHairBack.imgNumber} and replacement hair is ${r.extendedHairBack.imgNumber}");
        }
        return replacement;
    }

    void makeOtherColorsDarker(Palette p, String sourceKey, List<String> otherColorKeys) {
        String referenceKey = sourceKey;
        for(String key in otherColorKeys) {
            palette.add(key, new Colour(p[referenceKey].red, p[referenceKey].green, p[referenceKey].blue)..setHSV(p[referenceKey].hue, p[referenceKey].saturation, 2*p[referenceKey].value / 3), true);
            referenceKey = key; //each one is progressively darker
        }
    }

    void randomizeColors() {
        List<String> names = new List<String>.from(palette.names);
        for(String name in names) {
            palette.add(name, new Colour(rand.nextInt(255), rand.nextInt(255), rand.nextInt(255)), true);
        }
    }

    void setQuirk() {
        Random rand  = new Random(seed);
        quirkButDontUse = Quirk.randomHumanQuirk(rand);
    }

    void randomizeNotColors() {
        int firstEye = -100;
        for(SpriteLayer l in renderingOrderLayers) {
            l.imgNumber = rand.nextInt(l.maxImageNumber+1);
            //keep eyes synced unless player decides otherwise
            if(firstEye > 0 && l.imgNameBase.contains("Eye")) l.imgNumber = firstEye;
            if(firstEye < 0 && l.imgNameBase.contains("Eye")) firstEye = l.imgNumber;
            if(l.imgNumber == 0) l.imgNumber = 1;
            if(l.imgNameBase.contains("Glasses") && rand.nextDouble() > 0.35) l.imgNumber = 0;
        }
    }

    List<String> getAllNeededDirectories() {
        List<String> ret = new List<String>();
        for(SpriteLayer layer in dataOrderLayers) {
            ret.add(layer.imgNameBase);
        }
        return ret;
    }



    void save() {
        int id = Doll.getFirstFreeID();
        window.localStorage["${Doll.localStorageKey}$id"] = toDataBytesX();
        //window.alert("Saved Doll $id!");
    }

    static Doll andAlchemizeDolls(List<Doll> dolls) {
        Random rand = new Random();
        Doll ret = Doll.randomDollOfType(rand.pickFrom(dolls).renderingType);
        dolls.removeWhere((Doll doll) => doll is NamedLayerDoll);
        for(Doll d in dolls) {
            for(int i = 0; i<ret.renderingOrderLayers.length; i++) {
                SpriteLayer mine = ret.renderingOrderLayers[i];
                SpriteLayer yours;
                if(d.renderingOrderLayers.length > i) yours = d.renderingOrderLayers[i];
                if(yours != null) {
                    //print("my ${mine} was ${mine.imgNumber}, your ${yours} was ${yours.imgNumber}, them together is ${mine.imgNumber & yours.imgNumber}");
                    int max = mine.maxImageNumber;
                    if(max == 0) max = 1;
                    mine.imgNumber = (mine.imgNumber & yours.imgNumber) % max;
                    //print("mine after alchemy is ${mine.imgNumber}");
                }
            }

            for(int i = 0; i<ret.palette.length; i++) {
                Colour mine = ret.palette[i];
                Colour yours;
                if(d.palette.length > i) yours = d.palette[i];
                if(yours != null) {
                    mine.red = (mine.red & yours.red) % 256;
                    mine.green = (mine.green & yours.green) % 256;
                    mine.blue = (mine.blue & yours.blue) % 256;
                }
            }
        }
        return ret;
    }

    static Doll orAlchemizeDolls(List<Doll> dolls) {
        dolls.removeWhere((Doll doll) => doll is NamedLayerDoll);
        Random rand = new Random();
        Doll ret = Doll.randomDollOfType(rand.pickFrom(dolls).renderingType);
        for(Doll d in dolls) {
            for(int i = 0; i<ret.renderingOrderLayers.length; i++) {
                SpriteLayer mine = ret.renderingOrderLayers[i];
                SpriteLayer yours;
                if(d.renderingOrderLayers.length > i) yours = d.renderingOrderLayers[i];
                if(yours != null) {
                    //print("my ${mine} was ${mine.imgNumber}, your ${yours} was ${yours.imgNumber}, them together is ${mine.imgNumber & yours.imgNumber}");
                    int max = mine.maxImageNumber;
                    if(max == 0) max = 1;
                    mine.imgNumber = (mine.imgNumber | yours.imgNumber) % max;
                    //print("mine after alchemy is ${mine.imgNumber}");

                }
            }

            for(int i = 0; i<ret.palette.length; i++) {
                Colour mine = ret.palette[i];
                Colour yours;
                if(d.palette.length > i) yours = d.palette[i];
                if(yours != null) {
                    mine.red = (mine.red | yours.red) % 256;
                    mine.green = (mine.green | yours.green) % 256;
                    mine.blue = (mine.blue | yours.blue) % 256;
                }
            }
        }
        return ret;
    }

    static Doll breedDolls(List<Doll> dolls) {
        dolls.removeWhere((Doll doll) => doll is NamedLayerDoll);
        Random rand = new Random();
        int firstEye = -113;
        Doll ret = Doll.randomDollOfType(rand.pickFrom(dolls).renderingType);
            for(int i = 0; i<ret.dataOrderLayers.length; i++) {
                SpriteLayer mine = ret.dataOrderLayers[i];
                Doll d = rand.pickFrom(dolls);
                SpriteLayer yours;
                if(d.dataOrderLayers.length > i) yours = d.dataOrderLayers[i];
                //for each doll in the thing, pick one to be the source of this part
                //if i don't pick any it's a 'mutant' since it's the random doll
                if(yours != null && rand.nextDouble() > .1) {
                    //print("my ${mine} was ${mine.imgNumber}, your ${yours} was ${yours.imgNumber}, them together is ${mine.imgNumber & yours.imgNumber}");
                    int max = mine.maxImageNumber;
                    if(max == 0) max = 1;
                    mine.imgNumber = yours.imgNumber % max; //dont' go over you dick
                    //print("mine after alchemy is ${mine.imgNumber}");
                    if(firstEye > 0 && mine.imgNameBase.contains("Eye")) mine.imgNumber = firstEye;
                    if(firstEye < 0 && mine.imgNameBase.contains("Eye")) firstEye = mine.imgNumber;
                }
            }

            for(int i = 0; i<ret.palette.length; i++) {
                Doll d = rand.pickFrom(dolls);
                Colour mine = ret.palette[i];
                Colour yours;
                if(d.palette.length > i) yours = d.palette[i];
                if(yours != null && rand.nextDouble() > .1) {
                    mine.red = yours.red;
                    mine.green =yours.green;
                    mine.blue = yours.blue;
                }
            }

        return ret;

    }

    //who is shogun???
    static int convertSentenceToNumber(String sentence) {
       // print("converting sentence ${sentence}");
        int ret = 0;
        for(int s in sentence.codeUnits) {
            //print ("code unit ${new String.fromCharCode(s)}");
            ret += s;
        }
        return ret;
    }

    static int getFirstFreeID() {
        //fuck you if you want to store more than 1k dolls.
        for(int i = 0; i<255; i++) {
            if(!window.localStorage.containsKey("${Doll.localStorageKey}$i")) return i;
        }
    }

    void copyPalette(Palette newP) {
        int i = 0;
        List<String> names = new List.from(palette.names);
        //handles if the two paletttes match, or not.
        for(String name in newP.names) {
            if(palette.names.contains(name)) {
                palette.add(name, newP[name], true);
            }else {
                if(i < palette.names.length)palette.add(names[i], newP[name], true);
            }
            i++;
        }
    }

    void load(ImprovedByteReader reader, String dataString) {
        Uint8List thingy = BASE64URL.decode(dataString);
        if(reader == null) {
            reader = new ImprovedByteReader(thingy.buffer, 0);
            reader.readExpGolomb(); //pop it off, i already know my type
        }
        try {
            initFromReader(reader, false);
            setDollNameFromString(dataString);//i know it has a name
        }catch(e) {
            initFromReaderOld(new OldByteBuilder.ByteReader(thingy.buffer,0),false);
        }
    }

    //i am assuming type was already read at this point. Type, Exo is required.
    //IMPORTANT: WHATEVER CALLS ME SHOULD try/catch FOR OLD DATA
    void initFromReader(ImprovedByteReader reader, [bool layersNeedInit = true]) {
        if(layersNeedInit) {
            //print("initalizing layers");
            initLayers();
        }
        int numColors = reader.readExpGolomb();
        print("Number of colors is $numColors");
        List<String> names = new List<String>.from(palette.names);
        names.sort();

        for(int i = 0; i< numColors; i++) {
            print("reading color ${names[i]}");
            Colour newColor = new Colour(reader.readByte(),reader.readByte(),reader.readByte());
            palette.add(names[i], newColor, true);
        }

        int numLayers = reader.readExpGolomb();
        print("Number of layers is $numLayers");
        for(int i = 0; i<numLayers; i++) {
            dataOrderLayers[i].loadFromReader(reader);
        }

    }


    void initFromReaderOld(OldByteBuilder.ByteReader reader, [bool layersNeedInit = true]) {
        if(layersNeedInit) {
            //print("initalizing layers");
            initLayers();
        }
        int numFeatures = reader.readExpGolomb();
        //print("I think there are ${numFeatures} features");
        int featuresRead = 2; //for exo and doll type

        List<String> names = new List<String>.from(palette.names);
        names.sort();
        for(String name2 in names) {
            featuresRead +=1;
            Colour newColor = new Colour(reader.readByte(),reader.readByte(),reader.readByte());
            palette.add(name2, newColor, true);
        }

        //layer is last so can add new layers.
        for(SpriteLayer l in dataOrderLayers) {
            //older strings with less layers
            //print("layer ${l.name}, features read is $featuresRead and num features is $numFeatures");

            //<= is CORRECT DO NOT FUCKING CHANGE IT OR THE LAST LAYER WILL GET EATEN. ALSO: Fuck you, i don't know why i have to have a try catch in there since that if statement SHOULD mean only try to read if there's more to read but what fucking ever it works.
            if(featuresRead <= numFeatures) {
                try {
                    l.loadFromReaderOld(reader); //handles knowing if it's 1 or more bytes
                    // print("reading (${l.name}), its ${l.imgNumber} ");
                }catch(exception, stackTrace) {
                    print("exo said I have $numFeatures and i've only read $featuresRead, but still can't read (${l.name}) for some reason. this is a caught error");
                    l.imgNumber = 0; //don't have.
                }
                //l.imgNumber = reader.readByte();
            }else {
                print("skipping a feature (${l.name}) i don't have in string");
                l.imgNumber = 0; //don't have.
            }
            // print("loading layer ${l.name}. Value: ${l.imgNumber} bytesRead: $featuresRead  numFeatures: $numFeatures");
            if(l.imgNumber > l.maxImageNumber) l.imgNumber = 0;
            featuresRead += 1;

        }
    }


    void setPalette(Palette chosen) {
        for(String name in chosen.names) {
            palette.add(name, chosen[name],true);
        }
    }



    void beforeSaving() {
        //nothing to do but other dolls might sync old and new parts
    }

    //what goes after a ?
    String toDataUrlPart() {
        String dataString = toDataBytesX();
        //need to escape name shit
        return Uri.encodeQueryComponent(dataString);
    }



    //first, the rendering type. (this will get taken off before being passed to the loader)
    //numColors, colors, numLayers, layers
    String toDataBytesX([ByteBuilder builder = null]) {
        if(dollName == null || dollName.isEmpty) dollName = name;

        beforeSaving();
        // print("saving to data bytes x");
        if(builder == null) builder = new ByteBuilder();
        builder.appendExpGolomb(renderingType); //value of 1 means homestuck doll, etc. exo whatever so can have more than 255 dolltypes becaues i am thinking ahead for once. you won't get any 'no way we'll have more than 250 dolls' from me anytime soon


        List<String> names = new List<String>.from(palette.names);
        names.sort();
        builder.appendExpGolomb(names.length); //for length of palette
        for(String name2 in names) {
            Colour color = palette[name2];
            print("saving color $name2 with value red ${color.red}, green${color.green} blue${color.blue}");
            builder.appendByte(color.red);
            builder.appendByte(color.green);
            builder.appendByte(color.blue);
        }

        builder.appendExpGolomb(dataOrderLayers.length); //for length of layers
        //layer is last so can add new layers
        for(SpriteLayer l in dataOrderLayers) {
            //print("adding ${l.name}  with value ${l.imgNumber} to data string builder.");
            l.saveToBuilder(builder);
            //builder.appendByte(l.imgNumber);
        }
        return "$label${BASE64URL.encode(builder.toBuffer().asUint8List())}";
    }

    void copyFromReaderWithDataString(ImprovedByteReader reader, String dataStringBackup) {

    }

    //legacy as of 6/18/18
    String toDataBytesXOld([ByteBuilder builder = null]) {
        beforeSaving();
       // print("saving to data bytes x");
        if(builder == null) builder = new ByteBuilder();
        int length = palette.names.length + 1;//one byte for doll type

        for(SpriteLayer layer in dataOrderLayers) {
            length += layer.numbytes;
        }
        builder.appendByte(renderingType); //value of 1 means homestuck doll
        builder.appendExpGolomb(length); //for length


        List<String> names = new List<String>.from(palette.names);
        names.sort();
        for(String name in names) {
           // print("saving color $name");
            Colour color = palette[name];
            builder.appendByte(color.red);
            builder.appendByte(color.green);
            builder.appendByte(color.blue);
        }

        //layer is last so can add new layers
        for(SpriteLayer l in dataOrderLayers) {
            //print("adding ${l.name}  with value ${l.imgNumber} to data string builder.");
            l.saveToBuilder(builder);
            //builder.appendByte(l.imgNumber);
        }

        return BASE64URL.encode(builder.toBuffer().asUint8List());
    }

    //if it's in url form, it has a ? right before the text.
    static String removeURLFromString(String ds) {
        List<String> ret = ds.split("?");
        if(ret.length == 1) return ret[0];
        return ret[1];
    }

    static String removeLabelFromString(String ds) {
        ds = Uri.decodeQueryComponent(ds); //get rid of any url encoding that might exist
        return ds.split("$labelPattern")[1];
    }

    void setDollNameFromString(String ds) {
        ds = Uri.decodeQueryComponent(ds); //get rid of any url encoding that might exist
        dollName = ds.split("$labelPattern")[0];
    }


    /* first part of any data string tells me what type of doll to load.*/
    static Doll loadSpecificDoll(String ds) {
        String dataString = removeURLFromString(ds);
        dataString = removeLabelFromString(ds);
        print("dataString is $dataString");
        Uint8List thingy = BASE64URL.decode(dataString);
        ImprovedByteReader reader = new ImprovedByteReader(thingy.buffer, 0);
        int type = reader.readExpGolomb();
       // print("type is $type");


        allDollsMappedByType[type].load(reader, dataString);
        return allDollsMappedByType[type];
    }

    static Doll randomHomestuckDoll() {
        Random rand = new Random();;
        WeightedList<Doll> choices = new WeightedList<Doll>();
        choices.addAll(<Doll>[new HomestuckTrollDoll(), new HomestuckDoll(), new HomestuckCherubDoll(), new HomestuckSatyrDoll()]);
        choices.add(new HomestuckBabyDoll(), 0.5);
        choices.add(new HomestuckGrubDoll(), 0.5);
        choices.add(new EggDoll(), 0.1);
        choices.add(new TrollEggDoll(), 0.1);
        return rand.pickFrom(choices);
    }

    /* first part of any data string tells me what type of doll to load.*/
    static Doll randomDollOfType(int type) {
        return allDollsMappedByType[type];
    }

    static List<SavedDoll> loadAllFromLocalStorage() {
        int last = 255; //don't care about first ree id cuz they can be deleted.
        List<SavedDoll> ret = new List<SavedDoll>();
        for(int i = 0; i< last; i++) {
            String dataString = window.localStorage["${Doll.localStorageKey}$i"];

            if(dataString != null) {
                Doll doll = loadSpecificDoll(dataString);
                ret.add(new SavedDoll(doll,i));
            }
        }
        return ret;
    }

    static Doll makeRandomDoll()  {
        Random rand = new Random();;
        WeightedList<Doll> dolls = new WeightedList<Doll>();
        dolls.add(new HomestuckDoll());
        dolls.add(new HomestuckTrollDoll());
        dolls.add(new ConsortDoll(),0.3);
        dolls.add(new DenizenDoll(),0.3);
        dolls.add(new QueenDoll(),0.3);
        dolls.add(new EggDoll(),0.05);
        dolls.add(new TrollEggDoll(), 0.05);
        dolls.add(new HomestuckBabyDoll(),0.1);
        dolls.add(new HomestuckGrubDoll(), 0.1);
        dolls.add(new DadDoll(),0.3);
        dolls.add(new BroDoll(),0.3);
        dolls.add(new MomDoll(),0.3);
        //return new BroDoll(); //hardcoded for testing
        return rand.pickFrom(dolls);
    }


}





class SavedDoll {
    Doll doll;
    int id;
    CanvasElement canvas;
    TextAreaElement textAreaElement;

    SavedDoll(this.doll, this.id) {

    }

    void drawSelf(Element container, dynamic refreshMethod) {
        Element bluh = new DivElement();
        bluh.style.display = "inline-block";
        container.append(bluh);
        renderSelfToContainer(bluh);
        renderDataUrlToContainer(bluh, refreshMethod);
    }


    Future<Null> renderSelfToContainer(Element container) async {
        canvas = new CanvasElement(width: doll.width, height: doll.height);
        container.append(canvas);
        DollRenderer.drawDoll(canvas, doll);
    }

    Future<Null> renderDataUrlToContainer(Element container, dynamic refreshMethod) async {
        Element bluh = new DivElement();
        container.append(bluh);
        textAreaElement = new TextAreaElement();
        textAreaElement.setInnerHtml(doll.toDataBytesX());
        bluh.append(textAreaElement);

        ButtonElement copyButton = new ButtonElement();
        bluh.append(copyButton);
        copyButton.setInnerHtml("Copy Doll $id");
        copyButton.onClick.listen((Event e) {
            textAreaElement.select();
            document.execCommand('copy');
        });

        ButtonElement deleteButton = new ButtonElement();
        bluh.append(deleteButton);
        deleteButton.setInnerHtml("Delete Doll $id");
        deleteButton.onClick.listen((Event e) {
            if(window.confirm("Are you sure you want to delete it???")) {
                window.localStorage.remove("${Doll.localStorageKey}$id");
                refreshMethod();
            }
        });

        AnchorElement a = new AnchorElement();
        a.href = "index.html?${doll.toDataBytesX()}";
        a.target = "_blank";
        a.text = "Edit Doll Link";
        bluh.append(a);
    }




}

//name color pair but short
class NCP
{
    String name;
    String styleString;

    NCP(String this.name, String this.styleString);

    void addToPalette(Palette p) {
        p.add(name, new Colour.fromStyleString(styleString), true);
    }

}