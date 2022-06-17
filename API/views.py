from django.http import JsonResponse
from django.shortcuts import render

from .. import vesselsMonitor
# Create your views here.

def get_data(request):
    data = vesselsMonitor.get_data()
    return JsonResponse(data)
