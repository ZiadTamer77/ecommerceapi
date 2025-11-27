from django.contrib import admin
from . import models


@admin.register(models.Customer)
class CustomerAdmin(admin.ModelAdmin):
    autocomplete_fields = ["user"]
    list_display = [
        "user__first_name",
        "user__last_name",
        "user__email",
        "phone",
        "birth_date",
    ]

    list_per_page = 10

    search_fields = [
        "user__first_name__istartswith",
        "user__last_name__istartswith",
    ]

    list_select_related = ["user"]
