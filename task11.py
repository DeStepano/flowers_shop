from peewee import *

database = PostgresqlDatabase('postgres', **{'user': 'postgres', 'password': 'jegor'})

class UnknownField(object):
    def __init__(self, *_, **__): pass

class BaseModel(Model):
    class Meta:
        database = database

class Client(BaseModel):
    client_id = AutoField(primary_key = True)
    first_name = TextField()
    last_name = TextField()
    login = TextField()
    password = TextField()

    class Meta:
        table_name = 'client'
        schema = 'db_project'

class Department(BaseModel):
    department_id = AutoField(primary_key = True)
    name = TextField()

    class Meta:
        table_name = 'department'
        schema = 'db_project'

class Employee(BaseModel):
    department = ForeignKeyField(column_name='department_id', field='department_id', model=Department, null=True)
    employee_id = IntegerField()
    first_name = TextField()
    last_name = TextField()
    salary = DecimalField(null=True)
    valid_from = DateField()
    valid_until = DateField(null=True)

    class Meta:
        table_name = 'employee'
        indexes = (
            (('employee_id', 'valid_from'), True),
        )
        schema = 'db_project'
        primary_key = CompositeKey('employee_id', 'valid_from')

class Order(BaseModel):
    client = ForeignKeyField(column_name='client_id', field='client_id', model=Client, null=True)
    date = DateField()
    employee = ForeignKeyField(backref='employee_employee_set', column_name='employee_id', field='valid_from', model=Employee, null=True)
    employee_valid_from = ForeignKeyField(backref='employee_employee_valid_from_set', column_name='employee_valid_from', field='valid_from', model=Employee, null=True)
    order_id = AutoField(primary_key=True)
    price_total = DecimalField(null=True)
    status = TextField()

    class Meta:
        table_name = 'order'
        schema = 'db_project'

class Product(BaseModel):
    description = TextField(null=True)
    name = TextField()
    price = DecimalField(null=True)
    product_id = AutoField(primary_key = True)
    quantity_available = IntegerField(null=True)

    class Meta:
        table_name = 'product'
        schema = 'db_project'

class OrderXProduct(BaseModel):
    order = ForeignKeyField(column_name='order_id', field='order_id', model=Order)
    product = ForeignKeyField(column_name='product_id', field='product_id', model=Product)
    quantity = IntegerField(null=True)

    class Meta:
        table_name = 'order_x_product'
        indexes = (
            (('order', 'product'), True),
        )
        schema = 'db_project'
        primary_key = CompositeKey('order', 'product')

class Supplier(BaseModel):
    city = TextField(null=True)
    name = TextField()
    phone_no = TextField(null=True)
    supplier_id = AutoField(primary_key = True)

    class Meta:
        table_name = 'supplier'
        schema = 'db_project'

class Supply(BaseModel):
    date = DateField()
    supplier = ForeignKeyField(column_name='supplier_id', field='supplier_id', model=Supplier, null=True)
    supply_id = AutoField(primary_key=True)

    class Meta:
        table_name = 'supply'
        schema = 'db_project'

class SupplyXProduct(BaseModel):
    product = ForeignKeyField(column_name='product_id', field='product_id', model=Product)
    quantity = IntegerField(null=True)
    supply = ForeignKeyField(column_name='supply_id', field='supply_id', model=Supply)

    class Meta:
        table_name = 'supply_x_product'
        indexes = (
            (('supply', 'product'), True),
        )
        schema = 'db_project'
        primary_key = CompositeKey('product', 'supply')


# now some queriees:


# CRUD

new_client = Client(first_name = "Janusz", last_name='Kowalski', login='bober', password='testtest')
new_client.save()

for client in Client.select():
    print(client.first_name, client.last_name)

janusz = Client.get(first_name='Janusz')
janusz.login = 'bóbr'
janusz.save()

assert Client.get(first_name='Janusz').delete_instance() == 1


# select + sort

for product in Product.select().where(Product.price >= 80000).order_by(Product.price.desc()):
    print(f"{product.name} : `{product.description}` only for {product.price} rubles!")

# joins

for user in (
    Client.select(Client.first_name, fn.SUM(Order.price_total).alias("total"))
    .join(Order)
    .group_by(Client.client_id)
    .order_by(fn.SUM(Order.price_total).desc())
):
    print(user.first_name, user.total)


# window functions
    

for order in (
    Order.select(Order.date, fn.SUM(Order.price_total).over(order_by=Order.date).alias('sum'))
):
    print(order.date, order.sum)
