/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("tveeo1e615olw8s")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "zjydmn0f",
    "name": "order",
    "type": "number",
    "required": false,
    "presentable": false,
    "unique": false,
    "options": {
      "min": null,
      "max": null,
      "noDecimal": false
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("tveeo1e615olw8s")

  // remove
  collection.schema.removeField("zjydmn0f")

  return dao.saveCollection(collection)
})
