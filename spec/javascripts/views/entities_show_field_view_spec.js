describe('Cocupu.Views.Entities.ShowFieldView', function() {
    var view;

    
    beforeEach(function() {
        $('body').append('<div id="showView"></div>');
        view = new Cocupu.Views.Entities.ShowFieldView({ model: {name: "Description", type: "Text Field", code: 'description', value: 'foobar' }});
    });
    afterEach(function() {
        view.remove();
        $('#showView').remove();
    });
    
    
    it('Can render, after which the DOM representation of the view will be visible.', function() {
        $("#showView").append(view.render().el)
        expect($('#showView').find('input').length).toBe(1);
        expect($('#showView').find('input[name=description][type="Text Field"]').val()).toBe('foobar');
        expect($('#showView').find('label[for=description]').text()).toBe('Description');
    });
});

