//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

mixin DataBinding {
  final Set<WeakReference<DataBinding>> _listeners = {};
  final Set<WeakReference<DataBinding>> _senders = {};

  void listen(DataBinding sender) {
    sender._listeners.add(WeakReference(this));
    _senders.add(WeakReference(sender));
  }

  void unlisten(DataBinding sender) {
    sender._listeners.remove(this);
    _senders.remove(sender);
  }

  void fire(String id) {
    for (var listener in _listeners) {
      assert(listener.target != null);
      listener.target?.on(this, id);
    }
  }

  void on(DataBinding sender, String id) {
    // override
  }

  Set<WeakReference<DataBinding>> getListeners() {
    return _listeners;
  }

  Set<WeakReference<DataBinding>> getSenders() {
    return _senders;
  }
}
