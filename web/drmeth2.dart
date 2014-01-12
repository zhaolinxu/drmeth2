import 'dart:html';

double lastTime = 0.0;
double unprocessedFrames = 0.0;

double meth=0.0;
double money=0.0;
double veloMeth=0.0;
double veloMoney=0.0;

DivElement slots;
Street street = new Street();
List<Building> buildings = [null, null, null, null, null];

class Street {
  int dealer = 0;
  int maxDealer = 2000;
  int priceDealer = 1000;
  
  Street();
}

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
  
  void buyAnotherone() {
    if(money > price) {
        money -= price;
        count++;
    }
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

void buyBuilding(String type) {
  var didBuy = false;
  void buyIf(Building e) {
    if(e != null && e.name == type) {
      e.buyAnotherone();
      didBuy = true;
    }
  }
  buildings.forEach(buyIf);
  
  if(!didBuy){
    switch (type) {
      case "Trailer":
        buildings.add(new Trailer());
        break;
      default:
        null;
    }
  }
  updateSlots();
}

void main() {
  initButtons();
  initSlots();
  
  buyBuilding("Trailer");
  
  window.animationFrame.then(update);
}

void initButtons() {
  querySelector("#imgCook")
    ..onClick.listen(cook);
  
  querySelector("#imgSell")
    ..onClick.listen(sell);
}

void initSlots() {
  slots = querySelector("#slots");
  
  for(int i = 0; i<=6; i++) {
    var newLabel = new LabelElement();
    slots.children.add(newLabel);
  }
}

void updateSlots() {
  slots.children[0].text = street.dealer.toString() + " / " + street.maxDealer.toString();
  
  for(int i = 0; i < buildings.length;i++) {
    var aktBui = buildings[i];
    if(aktBui != null) {
      slots.children[i+1].text = aktBui.count.toString() + " " + aktBui.name + " " + aktBui.worker.toString() + " / " + aktBui.maxWorker.toString();
    }
  }
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
  
  window.animationFrame.then(update);
}

void updateVelos() {
  veloMeth = 0.0;
  for(int i = 0; i<buildings.length; i++){
    if(buildings[i] != null) veloMeth += buildings[i].methVelo;
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