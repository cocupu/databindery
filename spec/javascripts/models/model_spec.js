describe('Cocupu.Models.Model', function() {
    it('should be defined', function() {
        expect(Cocupu.Models.Model).toBeDefined();
    });

    it('can be instantiated', function() {
        var task = new Cocupu.Models.Model();
        expect(task).not.toBeNull();
    });
});



