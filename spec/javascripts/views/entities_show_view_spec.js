describe('Cocupu.Views.Entities.ShowView', function() {
    var view;
    
    beforeEach(function() {
        $('body').append('<div id="panels"></div>');
        var model = new Cocupu.Models.Model({label: 'foobar'});
        var entity = new Cocupu.Models.Entity({data: {foobar: 'bazbaz'}, persistent_id: '123-231' } );
        var stub = sinon.stub(entity, 'model').returns(model);
        view = new Cocupu.Views.Entities.ShowView({ model: entity });
    });
    
    afterEach(function() {
        view.remove();
        $('#panels').remove();
    });
    
    it('Should have some classes.', function() {
        expect(view.render().el.className).toBe('showView panel');
    });
    
    it('Is backed by a model instance, which provides the data.', function() {
        expect(view.model).toBeDefined();
        expect(view.model.get('persistent_id')).toBe("123-231");
    });
    
    it('Can render, after which the DOM representation of the view will be visible.', function() {
        $("#panels").append(view.render().el)
        expect($('#panels').find('.showView').length).toBe(1);
    });
    
    it('Can use an events hash to wire up view methods to DOM elements.', function() {
        //  var todoEl = view.render().el;
        //  var todoList = $('#todoList');

        //  todoList.append(todoEl);
        //  var viewEl = todoList.find('li input.check');//.filter(':first');

        //  console.log(viewEl);

        //   

        //   expect(viewEl.length).toBeGreaterThan(0);
        //     

        // runs(function() {
        //     // Hint: How would you trigger the view, via a DOM Event, to toggle the 'done' status.
        //     //       (See todos.js line 70, where the events hash is defined.)
        //     //
        //     // Hint: http://api.jquery.com/click
        //     viewEl.click();
        //     expect(view.model.get('done')).toBe(true);
        // });
    });
});
