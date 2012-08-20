describe('Cocupu.Models.Entity', function() {
    it('should be defined', function() {
        expect(Cocupu.Models.Entity).toBeDefined();
    });

    it('can be instantiated', function() {
        var entity = new Cocupu.Models.Entity();
        expect(entity).not.toBeNull();
    });

    it('can have a title when a label is defined', function() {
       var model = new Cocupu.Models.Model({label: 'foobar'});
       var entity = new Cocupu.Models.Entity({data: {foobar: 'bazbaz' }} );
       var stub = sinon.stub(entity, 'model').returns(model);
       expect(entity.title()).toEqual('bazbaz')
    });

    it('can have a title when a label is not defined', function() {
       var model = new Cocupu.Models.Model();
       var entity = new Cocupu.Models.Entity({data: {foobar: 'bazbaz'}, persistent_id: '123-231' } );
       var stub = sinon.stub(entity, 'model').returns(model);
       expect(entity.title()).toEqual('123-231')
    });
});
