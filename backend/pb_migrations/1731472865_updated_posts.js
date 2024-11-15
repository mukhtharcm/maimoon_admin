/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("tveeo1e615olw8s")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "8nk2tzqx",
    "name": "tags",
    "type": "relation",
    "required": false,
    "presentable": false,
    "unique": false,
    "options": {
      "collectionId": "stn18iasqgzl6a1",
      "cascadeDelete": false,
      "minSelect": null,
      "maxSelect": null,
      "displayFields": null
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("tveeo1e615olw8s")

  // remove
  collection.schema.removeField("8nk2tzqx")

  return dao.saveCollection(collection)
})
