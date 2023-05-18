//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

mixin DataBinding {
  final Set<DataBinding> _listeners = {};
  final Set<DataBinding> _senders = {};

  void listen(DataBinding sender) {
    sender._listeners.add(this);
    _senders.add(sender);
  }

  void unlisten(DataBinding sender) {
    sender._listeners.remove(this);
    _senders.remove(sender);
  }

  void fire(String id) {
    for (var listener in _listeners) {
      listener.on(this, id);
    }
  }

  void on(DataBinding sender, String id) {
    // override
  }

  Set<DataBinding> getListeners() {
    return _listeners;
  }

  Set<DataBinding> getSenders() {
    return _senders;
  }
}
