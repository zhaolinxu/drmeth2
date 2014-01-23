import 'dart:html';
import 'dart:convert' show JSON;
import 'dart:async' show Future;

double lastTime = 0.0;
double unprocessedFrames = 0.0;

double meth=0.0;
double money=10000.0;
double veloMeth=0.0; //do i really need those velos?
double veloMoney=0.0;
double purity = 0.2; //in percent

DivElement slots;
DivElement slotBuy;
DivElement shop;
Street street = new Street();
List<Building> buildings = [];

class Street {
  int dealer = 0;
  int maxDealer = 2000;
  int priceDealer = 1000;
  
  Street();
  
  void buyDealer() {
    if(money >= priceDealer && dealer < maxDealer) {
      money -= priceDealer;
      dealer++;
      updateSlots();
    }
  }
  
  double get sellVelo => dealer * 0.3/60;
  
  void sell(double amountMeth) {
    meth -= amountMeth;
    money += amountMeth * purity * 1.5; //will have to balance. 
  }
}

class Building {
  String name;
  int slotID = -1;
  int count=0;
  int worker=0;
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
        updateSlots();
    }
  }
  
  void buyWorker() {
    if(money > priceWorker && worker < maxWorker) { // make the button disable later!
      money -= priceWorker;
      worker++;
      updateSlots();
    }
  }
  
  double get methVelo {
    return worker * methPerSecond / 60;
  }
}

void buyBuilding(String type) {
  void buyIf(Building e) {
    if(e != null && e.name == type) {
      if(e.count == 0) e.slotID = slots.children.length; // won't work if an slot item get deleted.
      
      e.buyAnotherone();
    }
    
  }
  buildings.forEach(buyIf);  
}

void main() {
  init();
  
  window.animationFrame.then(update);
}

ParagraphElement slotBuyButton(int slotID) {
  var button = new ParagraphElement();
  button..text = "Buy a Worker"
      ..onClick.listen((e) => buildings[getIndexFromSlotID(slotID)].buyWorker());
  
  return button;
}

int getIndexFromSlotID(int slotID) {
  for(int i = 0; i < buildings.length; i++) {
    if(buildings[i].slotID == slotID) {
      return i;
    }
  }
  return -1;
}

void updateSlots() {
  slots.children[0].text = "da street " +street.dealer.toString() + " / " + street.maxDealer.toString();
  
  for(int i = 0; i < buildings.length;i++) {
    var aktBui = buildings[i];
    if(aktBui != null && aktBui.count > 0) {
      if(aktBui.slotID >= slots.children.length) {
        slots.children.add(new ParagraphElement());
        slotBuy.children.add(slotBuyButton(aktBui.slotID));
      }
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

void calculateMethVelo() {
  veloMeth = 0.0;
  for(int i = 0; i<buildings.length; i++){
    if(buildings[i] != null) veloMeth += buildings[i].methVelo;
  }
}

void tick() {
  calculateMethVelo();
  meth += veloMeth;
  
  if(street.sellVelo < meth) street.sell(street.sellVelo);
  else street.sell(meth);
}

void render() {
  updateLabels();
}

void cook(MouseEvent e) {
  meth += 1 + meth*0.01;
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
  
  querySelector("#labelPurity")
    ..text = (purity*100).round().toString() + " %";
}

void init() {
  void initButtons() {
    querySelector("#imgCook")
    ..onClick.listen(cook);
  
  querySelector("#imgSell")
    ..onClick.listen(sell);
}
  
  void initShop() {
    shop = querySelector("#shop");
    
    void createButton(Building b) {
      var button = new ParagraphElement();
      button..text = b.price.toString() + " " + b.name
          ..onClick.listen((e) => buyBuilding(b.name));
      
      shop.children.add(button);
    }
    
    buildings.forEach(createButton);
  }

  void initSlots() {
    slots = querySelector("#slots");
    slotBuy = querySelector("#slotBuy");
    
    var streetLabel = new ParagraphElement();
    streetLabel..text = "da street " + street.dealer.toString() + " / " + street.maxDealer.toString();
    
    var buyDealerButton = new ParagraphElement();
    buyDealerButton..text = "Buy a Dealer"
        ..onClick.listen((e) => street.buyDealer());
    
    slots.children.add(streetLabel);
    
    slotBuy.children.add(buyDealerButton);
  }
  
  void buildBuildings(String jsonString) {
    Map blueprint = JSON.decode(jsonString);
    
    buildings.add(new Building(blueprint['a'][0], blueprint['a'][1], blueprint['a'][2], blueprint['a'][3], blueprint['a'][4]));
    buildings.add(new Building(blueprint['b'][0], blueprint['b'][1], blueprint['b'][2], blueprint['b'][3], blueprint['b'][4]));
    initShop();
    initSlots();
  }
  
  Future loadJSON(){
    return HttpRequest.getString("blueprint.json")
        .then(buildBuildings);
  }
  initButtons();
  loadJSON();
}

void loadTrailer(){
  void buildBuildings(String jsonString) {
    Map blueprint = JSON.decode(jsonString);
    
    buildings[0] = new Building(blueprint[0][0], blueprint[0][1], blueprint[0][2], blueprint[0][3], blueprint[0][4]);
  }
  
  

}