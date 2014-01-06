import 'dart:html';

int money=0;
int meth=0;

void main() {
  querySelector("#imgCook")
    ..onClick.listen(cook);
  
  querySelector("#imgSell")
    ..onClick.listen(sell);
  
  updateButtons();
}

void cook(MouseEvent event) {
  meth++;
  updateButtons();
}

void sell(MouseEvent event) {
  if(meth > 0) {
    meth--;
    money++;
    updateButtons();
  }
}

void updateButtons() {
  querySelector("#buttonCook")
    ..text = "$meth g";
  
  querySelector("#buttonSell")
    ..text = "$money Dollar";
}