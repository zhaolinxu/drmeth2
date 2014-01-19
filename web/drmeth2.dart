import 'dart:html';

double lastTime = 0.0;
double unprocessedFrames = 0.0;

double meth=0.0;
double money=50000000.0;
double veloMeth=0.0;
double veloMoney=0.0;

DivElement slots;
DivElement shop;
Street street = new Street();
List<Building> buildings = [new Trailer(), new House()];

class Street {
  int dealer = 0;
  int maxDealer = 2000;
  int priceDealer = 1000;
  
  Street();
  
  void buyDealer(Event e) {
    if(money >= priceDealer && dealer < maxDealer) {
      money -= priceDealer;
      dealer++;
    }
  }
}

abstract class Building {
  String name;
  int slotID;
  int count=0;
  bool justBoughtAnotherone = false;
  int worker=0;
  bool justBoughtWorker = false;
  int _maxWorker;
  int priceWorker;
  double methPerSecond;
  int price;
  
  Building(String name, int price, int maxWorker, int priceWorker, double methPerSecond) {
    this.name = name;
    this.price = price;
    this._maxWorker = maxWorker;
    this.priceWorker = priceWorker;
    this.methPerSecond = methPerSecond;
  }
  
  int get maxWorker {
    return _maxWorker * count;
  }
  
  void buyAnotherone() {
    if(money > price) {
        money -= price;
        count++;
    }
  }
  
  void buyWorker(MouseEvent e) {
    if(money > priceWorker && worker < maxWorker) { // make the button disable later!
      money -= priceWorker;
      worker++;      
    }
  }
  
  double get methVelo {
    return worker * methPerSecond / 60;
  }
}

class Trailer extends Building {
  Trailer() : super("Trailer", 2000, 5, 500, 0.1);
}

class House extends Building {
  House() : super("House", 100000, 10, 5000, 0.2);
}

void buyBuilding(String type) {
  void buyIf(Building e) {
    if(e != null && e.name == type) {
      e.buyAnotherone();
      
      if(e.count == 1) e.slotID = slots.children.length; // won't work if an slot item get deleted.
    }
    
  }
  buildings.forEach(buyIf);
  updateSlots();
  
}

LIElement createSlotLIElement(Building aktBui){
  LIElement le = new LIElement();
  le.text = aktBui.count.toString() + " " + aktBui.name + " " + aktBui.worker.toString() + " / " + aktBui.maxWorker.toString();
  return le;
}

void main() {
  initButtons();
  initSlots();
  initShop();
  
  window.animationFrame.then(update);
}

void initButtons() {
  querySelector("#imgCook")
    ..onClick.listen(cook);
  
  querySelector("#imgSell")
    ..onClick.listen(sell);
}

void initShop() {
  shop = querySelector("#shop");
  
  void createButton(Building b) {
    var button = new ParagraphElement(); //make this for a list of all possible buildings.
    button..text = b.price.toString() + " " + b.name
        ..onClick.listen((e) => buyBuilding(b.name));
    
    shop.children.add(button);
  }
  
  buildings.forEach(createButton);
}

void initSlots() {
  slots = querySelector("#slots");
  var streetLabel = new ParagraphElement();
  streetLabel..text = street.dealer.toString() + " / " + street.maxDealer.toString()
            ..onClick.listen(street.buyDealer);
  slots.children.add(streetLabel);
}

void updateSlots() {
  slots.children[0].text = street.dealer.toString() + " / " + street.maxDealer.toString();
  
  for(int i = 0; i < buildings.length;i++) {
    var aktBui = buildings[i];
    if(aktBui != null && aktBui.count > 0) {
      if(aktBui.slotID >= slots.children.length) slots.children.add(new ParagraphElement());
      slots.children[aktBui.slotID].text = aktBui.count.toString() + " " + aktBui.name + " " + aktBui.worker.toString() + " / " + aktBui.maxWorker.toString();
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
    ..text = meth.floor().toString() + " g";
  
  querySelector("#labelMoney")
    ..text = money.floor().toString() + " Dollar";
}