/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("iebpm9k0j0rkzrg")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "qajj7w8b",
    "name": "description",
    "type": "text",
    "required": false,
    "presentable": false,
    "unique": false,
    "options": {
      "min": null,
      "max": null,
      "pattern": ""
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("iebpm9k0j0rkzrg")

  // remove
  collection.schema.removeField("qajj7w8b")

  return dao.saveCollection(collection)
})
