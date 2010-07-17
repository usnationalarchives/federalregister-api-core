/**
 * @param {String} [color='#AAA'] placeholder text color
 */
jQuery.fn.textPlaceholder = function (color) {

	color = color || '#AAA';

	return this.each(function(){

		var that = this;

		if (that.placeholder && 'placeholder' in document.createElement(that.tagName)) return;

		var default_color = that.style.color;
		var placeholder = that.getAttribute('placeholder');
		var input = $(that);

		if (that.value === '' || that.value == placeholder) {
			that.value = placeholder;
			that.style.color = color;
			input.data('placeholder-visible', true);
		}

		input.focus(function(){
			this.style.color = default_color;
			if (input.data('placeholder-visible')) {
				input.data('placeholder-visible', false);
				this.value = '';
			}
		});

		input.blur(function(){
			if (this.value === '') {
				input.data('placeholder-visible', true);
				this.value = placeholder;
				this.style.color = color;
			} else {
				this.style.color = default_color;
				input.data('placeholder-visible', false);
			}
		});

		that.form && $(that.form).submit(function(){
			if (input.data('placeholder-visible')) {
				that.value = '';
			}
		});

	});

};