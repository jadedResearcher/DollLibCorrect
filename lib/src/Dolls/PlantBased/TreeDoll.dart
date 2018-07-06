import 'dart:async';
import 'dart:html';
import 'dart:math' as Math;
import 'package:DollLibCorrect/src/Dolls/PlantBased/FlowerDoll.dart';
import 'package:DollLibCorrect/src/Dolls/PlantBased/FruitDoll.dart';
import 'package:DollLibCorrect/src/Dolls/Layers/PositionedDollLayer.dart';
import 'package:DollLibCorrect/src/Dolls/Layers/PositionedLayer.dart';
import 'package:DollLibCorrect/src/Dolls/PlantBased/LeafDoll.dart';
import 'package:RenderingLib/RendereringLib.dart';
import 'package:CommonLib/Compression.dart';

import "../../Dolls/Doll.dart";
import "package:DollLibCorrect/src/Dolls/KidBased/HomestuckDoll.dart";
import "package:DollLibCorrect/src/Dolls/Layers/SpriteLayer.dart";
import "dart:typed_data";
import 'dart:convert';
import "../../Rendering/ReferenceColors.dart";
import "../Quirk.dart";


/*

prototype for a doll that has positioned layers
 */


class TreeDoll extends Doll{

    List<TreeForm> forms = new List<TreeForm>();
    //for drawing leaves on, only want to get branches once
    CanvasElement branchCache;
    //for drawing fruit and other hangables only want to get tree once
    CanvasElement leavesAndBranchCache;

    @override
    List<Palette> validPalettes = new List<Palette>.from(ReferenceColours.paletteList.values);


    TreeForm get form {
        for(TreeForm form in forms) {
            if(form.hasForm(this)) return form;
        }
        //just assume it's a tree
        return forms.first;
    }

  int minFruit = 13;
  int maxFruit = 33;
  int minLeaf = 13;
  int maxLeaf = 33;




  @override
  String originalCreator = "jadedResearcher and dystopicFuturism";

  @override
  int renderingType =33;

  @override
  int width = 500;
  @override
  int height = 500;

  @override
  String name = "Tree";

  @override
  String relativefolder = "images/Tree";
  final int maxBranches = 27;
  final int maxLeaves = 12;

  int fruitWidth = 50;
  int fruitHeight = 50;
    int leafWidth = 100;
    int leafHeight = 100;


  SpriteLayer branches;
  PositionedLayer leavesFront;
  PositionedLayer leavesBack;

    //TODO think about how i wanna do flowers/fruit, wont know how many to have will I?

  //not a get, so i can add flowers/fruit to it over time.
  @override
  List<SpriteLayer>   renderingOrderLayers = new List <SpriteLayer>();
  @override
  List<SpriteLayer>   dataOrderLayers =new List <SpriteLayer>();


  @override
  Palette palette = new HomestuckPalette()
    ..accent = '#FF9B00'
    ..aspect_light = '#FF9B00'
    ..aspect_dark = '#FF8700'
    ..shoe_light = '#7F7F7F'
    ..shoe_dark = '#727272'
    ..cloak_light = '#A3A3A3'
    ..cloak_mid = '#999999'
    ..cloak_dark = '#898989'
    ..shirt_light = '#EFEFEF'
    ..shirt_dark = '#DBDBDB'
    ..pants_light = '#C6C6C6'
    ..eye_white_left = '#ffffff'
    ..eye_white_right = '#ffffff'
    ..pants_dark = '#ADADAD'
    ..hair_main = '#ffffff'
    ..hair_accent = '#ADADAD'
    ..skin = '#ffffff';

  //for making random trees in the randomdolloftype method, don't let it recurse and need ever more fruit.
  //(to make one tree with random doll fruit, i would need to make another tree to genererate a random doll)
  bool barren = false;

  TreeDoll([bool this.barren = false]) {
      //print("making a new tree");
      forms.addAll(<TreeForm>[new TreeForm(), new BushForm(), new LeftForm(), new RightFrom()]);
      rand.nextInt(); //init;
      initPalettes();
      initLayers();
      randomize();
  }

  void initPalettes() {
      for(int i = 0; i < 13*2; i++) {
          validPalettes.add(makeRandomPalette());
      }
  }



  //HELL YES i found the source of the save bug.
  //i'm not supposed to use premade palettes like this, instead,
  //how does the drop downs work?
  @override
  void randomizeColors() {
    if(rand == null) rand = new Random();;

    Palette newPallete = rand.pickFrom(validPalettes);
    copyPalette(newPallete);
  }

  @override
  void randomizeNotColors() {
      //print("randomizing not colors, rendering order layers is $renderingOrderLayers");
    for(SpriteLayer l in renderingOrderLayers) {
      l.imgNumber = rand.nextInt(l.maxImageNumber+1);
    }

    //make clusters instead
    if(rand.nextBool()) {
        leavesFront.imgNumber = 0;
        leavesBack.imgNumber = 0;
    }
  }

  @override
  void setQuirk() {
    Random rand  = new Random(seed);
    quirkButDontUse = Quirk.randomHumanQuirk(rand);

  }

  @override
    Doll spawn() {
        TreeDoll copy = this.clone();
        copy.renderingOrderLayers.clear();
        copy.initLayers();
        copy.randomize();
        return copy;
    }

  /*
    pick a valid ish point at random
    draw this tree (no color replacement).
    check right and down from this point till you find a valid point. if you never do, give up.
    (never look left and up because whatever, this should be good enough for now)

    if it's not for leaf, then in addition to leaves front and back, it ALSO checks for cluster leaves
   */

  Future<Null> getBranchCache() async {
      if(branchCache == null) {
          branchCache = new CanvasElement(
              width: width, height: height);
          //not a for loop because don't do fruit
          await branches.drawSelf(branchCache);
      }

      return branchCache;
  }


  Future<Null> getTreeCache() async {
      if(leavesAndBranchCache == null) {
          leavesAndBranchCache = new CanvasElement(
              width: width, height: height);
          await leavesFront.drawSelf(leavesAndBranchCache);
          await branches.drawSelf(leavesAndBranchCache);
          await leavesBack.drawSelf(leavesAndBranchCache);
          List<SpriteLayer> tmp = clusters;
          for (SpriteLayer l in tmp) {
              await l.drawSelf(leavesAndBranchCache);
          }
      }
      return leavesAndBranchCache;
  }

  Future<Math.Point> randomValidPointOnTree(bool forLeaf) async {
      //print("looking for a valid point on tree");
      int xGuess = randomValidHangableX();
      if(xGuess == form.canopyWidth) xGuess = form.leafX;
      int yGuess = randomVAlidHangableY();
      if(yGuess == form.canopyHeight) yGuess = form.leafY;
      CanvasElement pointFinderCanvas;
      //handles caching shit, no need to redraw for each leave/fruit
      if(forLeaf) {
          pointFinderCanvas = await getBranchCache();
      }else {
          pointFinderCanvas = await getTreeCache();
      }

      //only look at leaf locations
      ImageData img_data = pointFinderCanvas.context2D.getImageData(xGuess, yGuess, form.canopyWidth-xGuess, form.canopyHeight-yGuess);
      for(int x = 0; x<form.canopyWidth-xGuess; x ++) {
          for(int y = 0; y<form.canopyHeight-yGuess; y++) {
              int i = (y * (form.canopyWidth-xGuess) + x) * 4;
              if(img_data.data[i+3] >100) {
                  //the '0' point for the data is xguess,yguess so take that into account.
                 // print("found valid position at ${x+xGuess}, ${y+yGuess} because alpha is ${img_data.data[i+3]}");
                  return keepInBounds(new Math.Point(x + xGuess, y + yGuess));
              }
          }

      }
      //print("returning null");
      return null;
  }

  Math.Point keepInBounds(Math.Point p) {
      int x = p.x;
      int y = p.y;
      if(p.x > width-bufferWidth) x = width-bufferWidth;
      if(p.x < bufferWidth) x = bufferWidth;

      if(p.y > height-bufferHeight) y = height-bufferHeight;
      if(p.y < bufferHeight) y = bufferHeight;
      return new Math.Point(x,y);

  }

  //leafs can be up to 1.5 times their base size
  int get bufferWidth => (leafWidth).round();
  int get bufferHeight => (leafHeight).round();


    int randomValidHangableX() {
      return rand.nextIntRange(form.leafX+bufferWidth, form.leafX + form.canopyWidth-bufferWidth);
  }

  int randomVAlidHangableY() {
      return rand.nextIntRange(form.leafY+bufferHeight, form.leafY + form.canopyHeight-bufferHeight);
  }

   Colour getRandomFruitColor() {
      //reds, purples, yellows are all valid, so lets go for hsv, max s and at least 50% v?
      double color = rand.nextDouble(0.16); //up to green
      //60 to 180 is green so avoid that
      //.16 to 0.5
      if(rand.nextBool()) {
          color = rand.nextDouble(0.5) + 0.5; //blue to pink
      }
      return new Colour.hsv(color,1.0,rand.nextDouble()+0.5);
  }

     Colour getRandomLeafColor() {
        //reds, purples, yellows are all valid, so lets go for hsv, max s and at least 50% v?
        double color = rand.nextDouble(0.44-0.16)+0.16;// up to green minus the reds
        return new Colour.hsv(color,rand.nextDouble()+0.5,rand.nextDouble()+0.1);
    }

     Colour getRandomBarkColor() {
        //reds, purples, yellows are all valid, so lets go for hsv, max s and at least 50% v?
        double color = rand.nextDouble(0.13);// up to yellow
        return new Colour.hsv(color,rand.nextDouble()+0.25,rand.nextDouble()+0.1);
    }

   Palette makeRandomPalette() {
      //print("making a random palette for $name");
      HomestuckPalette newPalette = new HomestuckPalette();

      newPalette.add(HomestuckPalette.SHOE_LIGHT, getRandomFruitColor(),true);
     makeOtherColorsDarker(newPalette, HomestuckPalette.SHOE_LIGHT, <String>[HomestuckPalette.SHOE_DARK, HomestuckPalette.ACCENT]);

      newPalette.add(HomestuckPalette.ASPECT_LIGHT, getRandomFruitColor(),true);
      makeOtherColorsDarker(newPalette, HomestuckPalette.ASPECT_LIGHT, <String>[HomestuckPalette.ASPECT_DARK]);

      newPalette.add(HomestuckPalette.HAIR_MAIN, getRandomFruitColor(),true);
      makeOtherColorsDarker(newPalette, HomestuckPalette.HAIR_MAIN, <String>[HomestuckPalette.HAIR_ACCENT]);

      newPalette.add(HomestuckPalette.SHIRT_LIGHT, getRandomBarkColor(),true);
      makeOtherColorsDarker(newPalette, HomestuckPalette.SHIRT_LIGHT, <String>[HomestuckPalette.SHIRT_DARK]);

      newPalette.add(HomestuckPalette.PANTS_LIGHT, getRandomBarkColor(),true);
      makeOtherColorsDarker(newPalette, HomestuckPalette.PANTS_LIGHT, <String>[HomestuckPalette.PANTS_DARK]);

      newPalette.add(HomestuckPalette.CLOAK_LIGHT, getRandomLeafColor(),true);
      makeOtherColorsDarker(newPalette, HomestuckPalette.CLOAK_LIGHT, <String>[HomestuckPalette.CLOAK_MID, HomestuckPalette.CLOAK_DARK]);
      return newPalette;
  }

  List<SpriteLayer> get hangables => renderingOrderLayers.where((SpriteLayer s) => s.name.contains("Hang") || s.name.contains("Dynamic")  );
    List<SpriteLayer> get clusters => renderingOrderLayers.where((SpriteLayer s) => s.name.contains("Cluster") || s.name.contains("Leaf"));

  bool hasHangablesAlready() {
      return hangables.isNotEmpty;
  }

    bool hasClustersAlready() {
        return clusters.isNotEmpty;
    }

  Future<Null> createLeafClusters() async {
      //print("leaf cluster being made, leavesfront is ${leavesFront.imgNumber}");
      if(leavesFront.imgNumber != 0 || hasClustersAlready()) return;
      //print ('first creating clusters');
      if(rand.nextBool()) {
            //less leaves but bigger on average
            minLeaf = (minLeaf/2).round();
            maxLeaf = (maxLeaf/2).round();
            leafWidth = leafWidth * 2;
            leafHeight = leafHeight * 2;

      }
      int amount = rand.nextIntRange(minLeaf,maxLeaf);
      LeafDoll doll = new LeafDoll();
      doll.rand = rand.spawn();
      doll.randomizeNotColors(); //now it will fit my seed.
      doll.copyPalette(palette);
      for(int i = 0; i < amount; i++) {
          LeafDoll clonedDoll = doll.clone();
          Math.Point point = await randomValidPointOnTree(true);
//          print("second point is $point and doll is $clonedDoll");

          if(point != null) {
              int xpos = point.x;
              int ypos = point.y;
              double scale = 0.5+rand.nextDouble()*1.5;
              int w = (leafWidth * scale).round();
              int h = (leafHeight * scale).round();
              if(rand.nextBool()) {
                  clonedDoll.orientation = Doll.TURNWAYS;
              }

              //don't rotate too much (still hang from the "top") but have some wiggle
              clonedDoll.rotation = rand.nextIntRange(-45, 45);
  //            print("rotation is set to be ${clonedDoll.rotation}");
              if(clonedDoll.rotation <0) clonedDoll.rotation = 365-clonedDoll.rotation;
              PositionedDollLayer newLayer = new PositionedDollLayer(clonedDoll, w, h, (xpos-w/2).round(), ypos-(h/2).round(), "LeafCluster$i");
              addDynamicLayer(newLayer);
          }
      }
    }

  Future<Null> createHangables() async {
      if(barren || hasHangablesAlready()) return;
        double chosenNum = rand.nextDouble();
        //print("creating hangables and chosen num is $chosenNum is it less than 0.45? ${chosenNum < 0.45}");
        if(chosenNum < 0.45) {
            await createFruit();
        }else if (chosenNum < 0.9) {
            await createFlowers();
        }else {
            await createGloriousBullshit();
        }
  }

  Future<Null> createFlowers() async {
     //print ('first creating flowers');
     int amount = rand.nextIntRange(minFruit,maxFruit);
     FlowerDoll doll = new FlowerDoll();
     doll.rand = rand.spawn();
     doll.randomizeNotColors(); //now it will fit my seed.
     doll.copyPalette(palette);
     for(int i = 0; i < amount; i++) {
         Math.Point point = await randomValidPointOnTree(false);
         //print("second point is $point");
         if(point != null) {
             int xpos = point.x;
             int ypos = point.y;


             PositionedDollLayer newLayer = new PositionedDollLayer(
                 doll.clone(), fruitWidth, fruitHeight, xpos, ypos, "Hanging$i");
             addDynamicLayer(newLayer);
         }
     }
     //print ("fourth is done");
  }

  Future<Null> createFruit() async{
      //print ('first creating fruit');
      int amount = rand.nextIntRange(minFruit,maxFruit);
      FruitDoll doll = new FruitDoll();
      doll.rand = rand.spawn();
      doll.randomizeNotColors(); //now it will fit my seed.
      doll.copyPalette(palette);
      for(int i = 0; i < amount; i++) {
          FruitDoll clonedDoll = doll.clone();
          Math.Point point = await randomValidPointOnTree(false);
          //print("second point is $point");

          if(point != null) {
              int xpos = point.x;
              int ypos = point.y;

              PositionedDollLayer newLayer = new PositionedDollLayer(clonedDoll, fruitWidth, fruitHeight, xpos, ypos, "Hanging$i");
              addDynamicLayer(newLayer);
          }
      }
      //print ("fourth is done");
  }

  Future<Null> createGloriousBullshit() async {
      int type = rand.pickFrom(Doll.allDollTypes);
      //print("creating glorious bullshit, type is $type");

      Doll doll = Doll.randomDollOfType(type);
      doll.rand = rand.spawn();
      doll.randomize(); //now it will fit my seed.
      doll.copyPalette(palette);

      int amount = rand.nextIntRange(minFruit,maxFruit);
      for(int i = 0; i < amount; i++) {
          Math.Point point = await randomValidPointOnTree(false);
          //print("point is $point");

          if(point != null) {
              int xpos = point.x;
              int ypos = point.y;
              PositionedDollLayer newLayer = new PositionedDollLayer(
                  doll.clone(), fruitWidth, fruitHeight, xpos, ypos,
                  "Hanging$i");
              addDynamicLayer(newLayer);
          }
      }
  }

  @override
  Future<Null> beforeRender() async{
      print ("doing a before render");
      leavesBack.x = form.leafX;
      leavesBack.y = form.leafY;
      leavesFront.x = form.leafX;
      leavesFront.y = form.leafY;
      await createLeafClusters();
      await createHangables();

  }

  @override
  void initLayers() {

      branches = new SpriteLayer("Branches","$folder/branches/", 1, maxBranches);
      leavesBack = new PositionedLayer(0,0,"BackLeaves","$folder/leavesBack/", 1, maxLeaves);
      leavesFront = new PositionedLayer(0,0,"FrontLeaves","$folder/leavesFront/", 1, maxLeaves);
      leavesBack.syncedWith.add(leavesFront);
      leavesFront.syncedWith.add(leavesBack);
      leavesBack.slave = true;
      //have to do it here because not a get, can be modified
      renderingOrderLayers = <SpriteLayer>[leavesBack,branches, leavesFront];
      dataOrderLayers = <SpriteLayer>[leavesBack,branches, leavesFront];
  }

}


//forms decide where valid leaf/flower/etc locations are

class TreeForm {
    List<int> branchesNumbers = <int>[5,6,7,8,9,20,21,22];
    int leafX = 75;
    int leafY = 0;
    int canopyWidth = 368;
    int canopyHeight = 300;

    bool hasForm(TreeDoll doll) {
        return branchesNumbers.contains(doll.branches.imgNumber);
    }
}


class BushForm extends TreeForm {
    @override
    List<int> branchesNumbers = <int>[0,1,2,3,4,23,24,25,26,27];
    @override
    int leafX = 75;
    @override
    int leafY = 150;
    @override
    int canopyWidth = 475;
    @override
    int canopyHeight = 400;
}

class LeftForm extends TreeForm {
    @override
    List<int> branchesNumbers = <int>[15,16,17,18,19];
    @override
    int leafX = 0;
    @override
    int leafY = 0;
    @override
    int canopyWidth = 475;
    @override
    int canopyHeight = 300;
}

class RightFrom extends TreeForm {
    @override
    List<int> branchesNumbers = <int>[10,11,12,13,14];
    @override
    int leafX = 150;
    @override
    int leafY = 0;
    @override
    int canopyWidth = 475;
    @override
    int canopyHeight = 300;
}