/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("stn18iasqgzl6a1")

  collection.createRule = "@request.auth.id!=''"
  collection.updateRule = "@request.auth.id!=''"
  collection.deleteRule = "@request.auth.id!=''"

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("stn18iasqgzl6a1")

  collection.createRule = null
  collection.updateRule = null
  collection.deleteRule = null

  return dao.saveCollection(collection)
})
