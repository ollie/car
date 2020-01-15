// Generated by CoffeeScript 2.5.0
(function() {
  this.Toggle = class Toggle {
    constructor() {
      var $items;
      this._handleClick = this._handleClick.bind(this);
      $items = $('[data-toggle-target]');
      $items.on('click', this._handleClick);
    }

    _handleClick(e) {
      var $source, $target;
      e.preventDefault();
      $source = $(e.currentTarget);
      $target = $($source.data('toggle-target'));
      return $target.toggleClass('d-none');
    }

  };

}).call(this);
