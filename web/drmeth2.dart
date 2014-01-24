import 'dart:html';
import 'dart:convert' show JSON;
import 'dart:async' show Future;

double lastTime = 0.0;
double unprocessedFrames = 0.0;

double meth=0.0;
double money=1000000.0;
//all velos are frame based (60fps)
double veloMeth=0.0; //how much meth your buildings make
double veloMethFlow = 0.0; // veloMeth minus the amout of meth sold by the dealers
double veloMoney=0.0; //amount of money you get

double purity = 20.0; //in percent

DivElement slots;
DivElement slotBuy;
DivElement shop;
Street street = new Street();
List<Building> buildings = [];

void save() {
  String saveString;
  
}

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
  
  double get sellVelo => dealer * 0.1/60;
}

class Building {
  String name;
  int slotID = -1;
  int count=0;
  int worker=0;
  int _maxWorker;
  int priceWorker;
  double methPerSecond;
  double purity;
  int price;
  
  Building(String name, int price, int maxWorker, int priceWorker, double methPerSecond, double ppurity) {
    this.name = name;
    this.price = price;
    this._maxWorker = maxWorker;
    this.priceWorker = priceWorker;
    this.methPerSecond = methPerSecond;
    this.purity = ppurity;
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
    void addBuilding(String key, List blueprint) {
      buildings.add(new Building(key, blueprint[0], blueprint[1], blueprint[2], blueprint[3], blueprint[4]));
    }
    
    Map blueprint = JSON.decode(jsonString);
    blueprint.forEach(addBuilding);
    
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

void calculateVelos() {
  veloMeth = 0.0;
  for(int i = 0; i<buildings.length; i++){
    if(buildings[i] != null) veloMeth += buildings[i].methVelo;
  }
  
  veloMethFlow = veloMeth;
  
  
  var sellAmount;
  if(street.sellVelo < meth) sellAmount = street.sellVelo;
  else sellAmount = meth;
  
  veloMoney = sellAmount * purity;
  veloMethFlow -= sellAmount;
  
  if(veloMeth > 0){
    var all = 0;
    for(int i = 0; i<buildings.length; i++) {
      if(buildings[i] != null && buildings[i].methVelo >= 0) all += buildings[i].purity*buildings[i].methVelo;
    }
  
    purity = all/veloMeth;
  }
}

void tick() {
  calculateVelos();
  meth += veloMethFlow;
  money += veloMoney;
  
  
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
    money += purity;
  }
}

void updateLabels() {
  calculateVelos();
  querySelector("#labelMeth")
    ..text = meth.floor().toString() + "g    - " + (veloMeth*60).toStringAsFixed(2) + "/" + (veloMethFlow * 60).toStringAsFixed(2) + "g / SEC";
  
  querySelector("#labelMoney")
    ..text = money.floor().toString() + " Dollar    - " + (veloMoney*60).toStringAsFixed(0) + "Dollar/SEC";
  
  querySelector("#labelPurity")
    ..text = (purity).toStringAsFixed(0) + " %";
}

