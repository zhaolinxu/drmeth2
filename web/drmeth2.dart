import 'dart:html';

double lastTime = 0.0;
double unprocessedFrames = 0.0;

double meth=0.0;
double money=0.0;
double veloMeth=0.0;
double veloMoney=0.0;

List<Building> buildings = new List<Building>(5); 

abstract class Building {
  String name;
  int count=1;
  bool justBoughtAnotherone = false;
  int worker=1;//beware
  bool justBoughtWorker = false;
  int maxWorker;
  int priceWorker;
  double methPerSecond;
  int price;
  
  Building(String name, int price, int maxWorker, int priceWorker, double methPerSecond) {
    this.name = name;
    this.price = price;
    this.maxWorker = maxWorker;
    this.priceWorker = priceWorker;
    this.methPerSecond = methPerSecond;
  }
  
  void buyAnotherone(MouseEvent e) {
    //if(!justBoughtAnotherone){
      
      if(money > price) {
        money -= price;
        count++;
      //  justBoughtAnotherone = true;
      }
    //}
  }
  
  void buyWorker(MouseEvent e) {
    if(money > priceWorker && worker < maxWorker*count) { // make the button disable later!
      money -= priceWorker;
      worker++;      
    }
  }
  
  double get methVelo {
    return worker * methPerSecond / 60;
  }
}

class Trailer extends Building {
  Trailer() : super("Trailer", 1, 5, 1, 1.1);
}

void buyTrailer(MouseEvent e) {
  buildings[0] = new Trailer();
  //updateTable();
}

void main() {
  initButtons();
  
  window.animationFrame.then(update);
}

void initButtons() {
  querySelector("#imgCook")
    ..onClick.listen(cook);
  
  querySelector("#imgSell")
    ..onClick.listen(sell);
  
  querySelector("#buyTrailer")
      ..onClick.listen(buyTrailer);
}

void update(double time) {
  double now = time;
  unprocessedFrames+=(now-lastTime)*60.0/1000.0; // 60 fps
  lastTime = now;
  if (unprocessedFrames>10.0) unprocessedFrames = 10.0; 
  while (unprocessedFrames>1.0) {
    tick();
    unprocessedFrames-=1.0;
  }
  render();
  
  updateTable(); //dunno
  
  window.animationFrame.then(update);
}

void updateVelos() {
  veloMeth = 0.0;
  for(int i = 0; i<buildings.length; i++){
    if(buildings[i] != null) veloMeth += buildings[i].methVelo;
  }
}

void updateTable() {
  if(buildings[0] != null){
    Building aktBui = buildings[0]; // add a for loop here later.
    querySelector("#slot1Count").text = aktBui.count.toString();
    querySelector("#slot1BuyAnotherone").onClick.listen(buildings[0].buyAnotherone);
    querySelector("#slot1Name").text = aktBui.name;
    var maxWorker = aktBui.maxWorker * aktBui.count;
    querySelector("#slot1Worker").text = aktBui.worker.toString() + " / " + maxWorker.toString();
    querySelector("#slot1BuyWorker").onClick.listen(buildings[0].buyWorker);
  }
}

void tick() {
  updateVelos(); // waaaaaay to often
  meth += veloMeth;
  money += veloMoney;
}

void render() {
  updateLabels();
}

void cook(MouseEvent e) {
  meth++;
}

void sell(MouseEvent e) {
  if(meth >= 1) {
    meth--;
    money++;
  }
}

void updateLabels() {
  querySelector("#labelMeth")
    ..text = meth.toStringAsFixed(0) + " g";
  
  querySelector("#labelMoney")
    ..text = money.toStringAsFixed(0) + " Dollar";
}