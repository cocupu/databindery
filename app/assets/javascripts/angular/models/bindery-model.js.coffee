angular.module('curateDeps').factory('BinderyModel', ['$resource', '$sanitize', ($resource, $sanitize) ->
        BinderyModel = $resource('/models/:modelId', { modelId:'@id' }, {
            update: { method: 'PUT' },
            query: {
                method: 'GET',
                isArray: false, # <- not returning an array
                transformResponse: (data, header) ->
                    wrapped = angular.fromJson(data);
                    angular.forEach(wrapped.items, (item, idx) ->
                        wrapped.items[idx] = new BinderyModel(item)  #<-- replace each item with an instance of the resource object
                    )
                    return wrapped;

            }
        })

        BinderyModel.prototype.addField = () ->
          this.fields.push({name: "New Field", code:"", type:"text"})

        BinderyModel.prototype.addAssociation = () ->
          this.associations.push({name: "New Association", code:"", type:"Has Many"})

        BinderyModel.prototype.columnDefsFromModel = () ->
          if this.fields.length + this.associations.length > 5
            fixedColumnWidth = true
          fieldsDefs = $.map(this.fields, (f, i) ->
            columnDef = {
              field:"data['"+$sanitize(f.code)+"']"
              displayName:f.name
      #        editableCellTemplate: '/assets/editField-textarea.html'
              editableCellTemplate: '/assets/editField-textfield.html'
      #        editableCellTemplate: '<input type="text" ng-model="row.entity.data[\''+$sanitize(f.code)+'\']"></input>'
            }
            if fixedColumnWidth
              columnDef["width"] = "120"
            return columnDef
          )
          associationsDefs = $.map(this.associations, (f, i) ->
            columnDef = {field:"associations['"+$sanitize(f.code)+"']", displayName:f.name, width:"120"}
            if fixedColumnWidth
              columnDef["width"] = "120"
            return columnDef
          )
          return fieldsDefs.concat(associationsDefs)

        return BinderyModel;
    ])