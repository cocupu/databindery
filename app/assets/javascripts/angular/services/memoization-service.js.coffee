angular.module('curateDeps').factory('memoService', [ () ->
  memoService = { cache: {}}

  memoService.lookup = (objectId) ->
    return this.cache[objectId]

  # Add object to cache or update existing entry in the cache
  memoService.createOrUpdate = (stuffToStore) ->
    if Array.isArray(stuffToStore)
      angular.forEach(stuffToStore, (object, idx) ->
        this.cache[object.id] = object
      )
    else
      object = stuffToStore
      this.cache[object.id] = object
    return stuffToStore

  return memoService
])