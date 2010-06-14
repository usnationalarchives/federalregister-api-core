jQuery.extend(  
    jQuery.expr[':'], {  
        regex: function(a, i, m, r) {  
            var r = new RegExp(m[3], 'i');  
            return r.test(jQuery(a).text());  
        }  
    }  
);  

jQuery.extend(
  jQuery.expr[':'], {
    Contains: "jQuery(a).text().toUpperCase().indexOf(m[3].toUpperCase())>=0"
});


// http://blog.mastykarz.nl/jquery-random-filter/
jQuery.jQueryRandom = 0;
jQuery.extend(
  jQuery.expr[":"], {
    random: function(a, i, m, r) {
        if (i == 0) {
            jQuery.jQueryRandom = Math.floor(Math.random() * r.length);
        };
        console.log(a);
        console.log(i);
        console.log(m);
        console.log(r);
        return i == jQuery.jQueryRandom;
    }
});