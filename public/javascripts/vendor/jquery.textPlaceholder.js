jQuery.fn.textPlaceholder = function () {

	return this.each(function(){

		var that = this;

		if (that.placeholder && 'placeholder' in document.createElement(that.tagName)) return;

		var placeholder = that.getAttribute('placeholder');
		var input = $(that);

		if (that.value === '' || that.value == placeholder) {
			input.addClass('text-placeholder');
			that.value = placeholder;
		}

		input.focus(function(){
			if (input.hasClass('text-placeholder')) {
				this.value = '';
				input.removeClass('text-placeholder')
			}
		});

		input.blur(function(){
			if (this.value === '') {
				input.addClass('text-placeholder');
				this.value = placeholder;
			} else {
				input.removeClass('text-placeholder');
			}
		});

		that.form && $(that.form).submit(function(){
			if (input.hasClass('text-placeholder')) {
				that.value = '';
			}
		});

	});

};
