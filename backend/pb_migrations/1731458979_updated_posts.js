/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("tveeo1e615olw8s")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "sx6hc36w",
    "name": "author",
    "type": "relation",
    "required": false,
    "presentable": false,
    "unique": false,
    "options": {
      "collectionId": "_pb_users_auth_",
      "cascadeDelete": false,
      "minSelect": null,
      "maxSelect": 1,
      "displayFields": null
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("tveeo1e615olw8s")

  // remove
  collection.schema.removeField("sx6hc36w")

  return dao.saveCollection(collection)
})
