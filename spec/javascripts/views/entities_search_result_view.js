describe('Cocupu.Views.Entities.SeachResultView', function() {
    var view;
    
    beforeEach(function() {
        $('body').append('<div id="result"></div>');
        var model = new Cocupu.Models.Model({label: 'foobar'});
        var entity = new Cocupu.Models.Entity({id: '999', data: {foobar: 'bazbaz'}, persistent_id: '123-231' } );
        var stub = sinon.stub(entity, 'model').returns(model);
        view = new Cocupu.Views.Entities.SearchResultView({ model: entity });
        $("#result").append(view.render().el)
    });
    
    afterEach(function() {
        view.remove();
        $('#result').remove();
    });

    
    it('Should have some classes.', function() {
        expect(view.render().el.className).toBe('searchResult ui-draggable');
    });
    it('Should have a data id.', function() {
        expect($(view.render().el).attr('data-id')).toBe('999');
    });
    
});
