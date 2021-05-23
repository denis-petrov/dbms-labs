// 3.1 get all collections
db.getCollectionNames()
db.student.find()

// 3.2 insert one
db.student.insertOne(
{
    "beginning_date": "2021-03-14",
    "date_birth": "2001-11-03",
    "email": "mail@mail.com",
    "finishing_date": "2023-03-14",
    "fit_test": [],
    "full_name": "Rita",
    "gender": false,
    "group_name": "PS-22",
    "phone": "112"
})

db.student.insertMany([
    {
        "beginning_date": "2021-03-14",
        "date_birth": "2001-11-03",
        "email": "mail@mail.com",
        "finishing_date": "2023-03-14",
        "fit_test": [],
        "full_name": "Rita2",
        "gender": false,
        "group_name": "PS-22",
        "phone": "112"
    }, {
        "beginning_date": "2021-03-14",
        "date_birth": "2001-11-03",
        "email": "mail@mail.com",
        "finishing_date": "2023-03-14",
        "fit_test": [],
        "full_name": "Rita3",
        "gender": false,
        "group_name": "PS-22",
        "phone": "112"
    }
])

// 3.3 delete
db.student.deleteOne({"fit_test" : []})
db.student.deleteMany({"fit_test" : []})


// 3.4 find records

// find by Id
db.student.find({ "_id" : ObjectId("60a0ec5aefd64f1f240c9f07" )})

// find by attribute 1 lvl
db.student.find({ "email" : "mail@mail.com" })

// find by nested attribute
db.student.find(
{ "fit_test" : {
        "name": "jump",
        "date_happen": "2021-11-11",
        "score": 12,
        "threshold_value": 10
    }
})

// find with AND
db.student.find({ $and : [{ "email" : "mail@mail.com" }, { "gender" : true }]})

// find with OR
db.student.find({ $or : [{ "email" : "mail@mail.com"}, { "gender" : true }]})

// find with comparable
db.student.find({ "email": { $eq : "mail@mail.com" }})

// find with 2 or more comparable operators
db.student.find({
    $and: [
        { "email": { $eq : "mail@mail.com" }},
        { "beginning_date" : { $gt : "2012-03-14" } }
    ]
} )

// find in array
db.student.find({
    "fit_test": {
        "name": "jump",
        "date_happen": "2021-11-11",
        "score": 12,
        "threshold_value": 10
    }
})

// find by array length
db.student.find({ "fit_test" : { $size : 2 } })

// find record without attribute
db.student.find({ "is_anime" : { $exists : true } })
db.student.find({ "is_anime" : { $exists : false } })



// 3.5 Update records

// change value in attribute
db.student.updateOne(
   { "_id" : ObjectId("60a0ec5aefd64f1f240c9f07" )},
   { $set:
      {
        beginning_date: "2000-11-11"
      }
   }
)
db.student.find()

// delete attribute in record
db.student.updateOne(
    { "_id" : ObjectId("60a0ec5aefd64f1f240c9f07" )},
    { $unset:
        {
            "email": 1
        }
    }, false, true
)

// add attribute to record
db.student.updateOne(
    { "_id" : ObjectId("60a0ec5aefd64f1f240c9f07" )},
    { $set :
        {
            create_time : "001"
        }
    }
)
db.student.find()
