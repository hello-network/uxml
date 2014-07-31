part of uxml;

/**
  * Provides base class for chrome effects.
  *
  * @author:ferhat@ (Ferhat Buyukkokten)
  */
class Effect extends UxmlElement{
  static int _idGen = 0;
  int _signature;

  List<Action> _actions;
  Object property;
  Object source;
  Object targetElement;
  Object value;

  Effect() : super() {
    _signature = _idGen++;
    _actions = <Action>[];
  }

  /**
   * Adds an action to perform when effect is activated.
   */
  void addAction(Action action) {
    _actions.add(action);
  }

   /**
    * Returns id for effect that is shared across clones.
    */
  String get id => _signature.toString();

  /**
   * Returns list of actions to execute for effect.
   */
  List<Action> get actions => _actions;

  Effect clone() {
    Effect newEffect = new Effect();
    newEffect._actions = _actions;
    newEffect.property = property;
    newEffect.source = source;
    newEffect.targetElement = targetElement;
    newEffect.value = value;
    newEffect._signature = _signature;
    return newEffect;
  }
}
