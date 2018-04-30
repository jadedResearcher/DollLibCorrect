import 'package:RenderingLib/RendereringLib.dart';

import "../Dolls/Doll.dart";
import "SpriteLayer.dart";
import "dart:typed_data";
import 'dart:convert';

import "../../DollRenderer.dart";
import "dart:html";
import 'dart:async';


class HomestuckGrubDoll extends HomestuckTrollDoll {

    @override
    String originalCreator = "karmicRetribution";
    
    @override
    int renderingType =13;
    @override
    String folder = "images/Homestuck";
    @override
    final int maxBody = 8;

    @override
    String name = "Grub";


    @override
    Palette palette = new HomestuckTrollPalette()
        ..accent = '#FF9B00'
        ..aspect_light = '#FF9B00'
        ..aspect_dark = '#FF8700'
        ..shoe_light = '#111111'
        ..shoe_dark = '#333333'
        ..cloak_light = '#A3A3A3'
        ..cloak_mid = '#999999'
        ..cloak_dark = '#898989'
        ..shirt_light = '#111111'
        ..shirt_dark = '#000000'
        ..pants_light = '#4b4b4b'
        ..eye_white_left = '#ffba29'
        ..eye_white_right = '#ffba29'
        ..pants_dark = '#3a3a3a'
        ..hair_accent = '#aa0000'
        ..hair_main = '#000000'
        ..skin = '#C4C4C4';



    HomestuckGrubDoll([int sign]) {
        initLayers();
        randomize();
        if(sign != null) {
           // print("sign is $sign");
            canonSymbol.imgNumber = sign;
            //print("used sign to set canon Symbol to ${canonSymbol.imgNumber}");

            //makes sure palette is sign appropriate
            randomize(false);
            //print("after randomize, canon symbol is ${canonSymbol.imgNumber}");

        }
    }


    void mutantWings([bool force = false]) {
        //grubs don't have wings. trolls do.
    }

    @override
    void randomizeNotColors()

    {
        super.randomizeNotColors();
        if(body.imgNumber >2) body.imgNumber = 2;
        canonSymbol.imgNumber = 0;
    }

    @override
    void regularEyes(older) {
        HomestuckPalette h = palette as HomestuckPalette;
        if(older) {
            palette.add(HomestuckPalette.EYE_WHITE_LEFT, new Colour.fromStyleString("#ffba29"), true);
            palette.add(HomestuckPalette.EYE_WHITE_RIGHT, new Colour.fromStyleString("#ffba29"), true);
        }else {
            h.add(HomestuckPalette.EYE_WHITE_LEFT, h.aspect_light, true);
            h.add(HomestuckPalette.EYE_WHITE_RIGHT, h.aspect_light, true);
        }
    }

    @override
    void randomizeColors()

    {
        super.randomizeColors();
        HomestuckPalette h = palette as HomestuckPalette;
        h.add(HomestuckPalette.EYE_WHITE_LEFT, h.aspect_light,true);
        h.add(HomestuckPalette.EYE_WHITE_RIGHT, h.aspect_light,true);

    }

    @override
    void randomize([bool chooseSign = true])

    {
        super.randomize(chooseSign);
        canonSymbol.imgNumber = 0;
        if(extendedBody.imgNumber >2) extendedBody.imgNumber = 2;
        HomestuckPalette h = palette as HomestuckPalette;
        h.add(HomestuckPalette.EYE_WHITE_LEFT, h.aspect_light,true);
        h.add(HomestuckPalette.EYE_WHITE_RIGHT, h.aspect_light,true);
    }

    @override
    void setUpWays() {
        print("body is ${body.imgNumber}");
        if(extendedBody.imgNumber == 7 || extendedBody.imgNumber == 8) {
           // print("upways is true");
            orientation = Doll.UPWAYS;
        }else {
            orientation = Doll.NORMALWAYS;
        }
    }

    @override
    void initLayers()

    {
        super.initLayers();
        body = new SpriteLayer("Body","$folder/Grub/", 0, maxBody);
        extendedBody = new SpriteLayer("Body","$folder/Grub/", 0, maxBody, supportsMultiByte: true);


    }

    HomestuckGrubDoll.fromDataString(String dataString){
        Uint8List thingy = BASE64URL.decode(dataString);
        ByteReader reader = new ByteReader(thingy.buffer, 0);
        int type = reader.readByte(); //not gonna use, but needs to be off before given to initFromReader
        initFromReader(reader, new HomestuckTrollPalette());
        if(extendedBody.imgNumber ==0) extendedBody.imgNumber = body.imgNumber;
        if(extendedHairBack.imgNumber ==0) extendedHairBack.imgNumber = hairBack.imgNumber;
        if(extendedHairTop.imgNumber ==0) extendedHairTop.imgNumber = hairTop.imgNumber;

        if(extendedLeftHorn.imgNumber ==0) extendedLeftHorn.imgNumber = leftHorn.imgNumber;
        if(extendedRightHorn.imgNumber ==0) extendedRightHorn.imgNumber = rightHorn.imgNumber;

    }

    //assumes type byte is already gone
     HomestuckGrubDoll.fromReader(ByteReader reader){
         initFromReader(reader,new HomestuckTrollPalette());
         if(extendedBody.imgNumber ==0) extendedBody.imgNumber = body.imgNumber;
         if(extendedHairBack.imgNumber ==0) extendedHairBack.imgNumber = hairBack.imgNumber;
         if(extendedHairTop.imgNumber ==0) extendedHairTop.imgNumber = hairTop.imgNumber;

         if(extendedLeftHorn.imgNumber ==0) extendedLeftHorn.imgNumber = leftHorn.imgNumber;
         if(extendedRightHorn.imgNumber ==0) extendedRightHorn.imgNumber = rightHorn.imgNumber;

     }







}