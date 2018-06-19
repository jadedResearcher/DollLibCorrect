import "HomestuckTrollDoll.dart";
import 'package:RenderingLib/RendereringLib.dart';
import 'package:CommonLib/Compression.dart';

import "../Dolls/Doll.dart";
import "SpriteLayer.dart";
import "dart:typed_data";
import 'dart:convert';

import "../Dolls/HomestuckDoll.dart";
import "../Rendering/ReferenceColors.dart";

class EggDoll extends HomestuckDoll {

    @override
    String originalCreator = "multipleStripes";

    @override
    int renderingType =66;

    @override
    final int maxBody = 13;

    @override
    String name = "Egg";

    EggDoll() {
        initLayers();
        randomize();
    }

    @override
    void initLayers()

    {
        super.initLayers();
        //only one thing different
        extendedBody = new SpriteLayer("Body","$folder/Egg/", 1, maxBody, supportsMultiByte: true);


    }






}