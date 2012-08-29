describe('Cocupu.Models.Model', function() {
    it('should be defined', function() {
        expect(Cocupu.Models.Model).toBeDefined();
    });

    it('can be instantiated', function() {
        var task = new Cocupu.Models.Model();
        expect(task).not.toBeNull();
    });

    it('can setTypeName', function() {
        var entity = new Cocupu.Models.Model();
        var mock = sinon.mock(entity)
        mock.expects('save').once();

        entity.set("associations", [{code: 'one', name: 'foo'}, {code: 'two', name: 'bar'}]);
        entity.setTypeName('associations', 'one', 'foobar');
        expect(entity.get('associations')).toEqual([{code: 'one', name: 'foobar'}, {code: 'two', name: 'bar'}]);
        expect(mock.verify()).toBe(true);
    });
});



