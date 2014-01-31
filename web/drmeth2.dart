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

double sellBonus = 1.0;
double cookBonus = 1.0;
double priceBonus = 1.0;

DivElement slots;
DivElement slotBuy;
DivElement shop;

ParagraphElement shopSwitchPara;
List shopBuyChildren = new List();
List shopHireChildren = new List();
List shopUpgradeChildren = new List();
List shopAchievmentChildren = new List();

Street street = new Street();
List<Building> buildings = [];

void save() {
  String saveString;
  
}

double get methprice { return purity * priceBonus; }

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
  
  double get sellVelo => dealer * 0.1/60 * sellBonus;
}

class Building {
  String name;
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
  
  void sell() {
    money += (count*price + worker*priceWorker)/2;
    count = worker = 0;
  }
}

void buyBuilding(int id) {
  buildings[id].count == 0 ? newSlot(id) : updateSlots(); // won't work if an slot item get deleted.
  buildings[id].buyAnotherone();
}

void sellBuilding(int id) {
  Element getElementFromId(List list, int id) {
    for(int i = 0; i < list.length; i++) {
      if(list[i].id == id.toString()) return list[i];
    }
  }
  
  buildings[id].sell();
  slots.children.remove(getElementFromId(slots.children, id));
  slotBuy.children.remove(getElementFromId(slotBuy.children, id));
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
void changeShopChildren(String state) {
  var children;
    switch (state) {
      case "shop": 
        children = shopBuyChildren;
        break;
      case "hire":
        children = shopHireChildren;
        break;
      case "upgrade":
        children = shopUpgradeChildren;
        break;
      case "achievment":
        children = shopAchievmentChildren;
    }
    
    shop.children.clear();
    shop.children.add(shopSwitchPara);
    shop.children.addAll(children);
  }
  
  void initShop() {
    shop = querySelector("#shop");
    
    for(int i = 0; i < buildings.length; i++) {
      var button = new ParagraphElement();
      button..text = buildings[i].price.toString() + " " + buildings[i].name
          ..onClick.listen((e) => buyBuilding(i));
      
      shopBuyChildren.add(button);
    }
    
    shopSwitchPara = new ParagraphElement();
    
    var states = ["shop", "hire", "upgrade", "achievment"];
    for(int i = 0; i< states.length;i++) {
      var but = new LabelElement();
      but..onClick.listen((e) => changeShopChildren(states[i]))
         ..text = states[i].toUpperCase(); 
      
      shopSwitchPara.children.add(but);
    }
    
    shop.children.add(shopSwitchPara);
  }

  
  
  void initSlots() {
    slots = querySelector("#slots");
    slotBuy = querySelector("#slotBuy");
    
    var streetImage = new ImageElement(src: "street.png");
    streetImage..text = "da street " + street.dealer.toString() + " / " + street.maxDealer.toString();
    
    var buyDealerButton = new ImageElement(src: "buyWorkerButton.png");
    buyDealerButton.onClick.listen((e) => street.buyDealer());
    
    var emptyB = new ImageElement(src: "emptyButton.png");
    slotBuy.children.add(emptyB);
    
    slots.children.add(streetImage);
    
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


Element slotBuyButton(int id) {
  var button = new ImageElement(src: "buyWorkerButton.png");
  button.onClick.listen((e) => buildings[id].buyWorker());
      return button;
}

Element slotSellButton(int id) {
  var button = new ImageElement(src: "sellBuildingButton.png");
  button.onClick.listen((e) => sellBuilding(id));
  
  return button;
}

void updateSlots() {
  slots.children[0].text = "da street " +street.dealer.toString() + " / " + street.maxDealer.toString();
  
  void updateBuildingSlots(Element e) {
    if(e.id != "") e.text = slotString(int.parse(e.id));
  }
  
  slots.children.forEach(updateBuildingSlots);
}

String slotString(int id) {
  Building aktBui = buildings[id];
  return aktBui.count.toString() + " " + aktBui.name + " " + aktBui.worker.toString() + " / " + aktBui.maxWorker.toString();
}

void newSlot(int id) {
  var par = new ImageElement(src : buildings[id].name.toLowerCase()+".png");
  par..text = slotString(id)
      ..id = id.toString();
  slots.children.add(par);
  
  ParagraphElement parBuy = new ParagraphElement();
  parBuy.id = id.toString();
  parBuy.children..add(slotBuyButton(id))
                 ..add(slotSellButton(id));
  slotBuy.children.add(parBuy);
}

void update(double time) {
  double now = time;
  unprocessedFrames+=(now-lastTime)*60.0/1000.0; // 60 fps
  lastTime = now;
  if (unprocessedFrames>10.0) unprocessedFrames = 10.0; 
  for(double uf = unprocessedFrames; uf>1.0; uf-= 1.0)
    tick();
  
  render();
  
  window.animationFrame.then(update);
}

void calculateVelos() {
  veloMeth = 0.0;
  for(int i = 0; i<buildings.length; i++){
    if(buildings[i] != null) veloMeth += buildings[i].methVelo;
  }
  veloMeth *= cookBonus;
  
  veloMethFlow = veloMeth;
  
  
  var sellAmount;
  street.sellVelo < meth ? sellAmount = street.sellVelo : sellAmount = meth;
  
  veloMoney = sellAmount * methprice;
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
    money += methprice;
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

