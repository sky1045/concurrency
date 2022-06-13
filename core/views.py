from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
import time

# Create your views here.
class IndexView(APIView):
    def get(self, request):
        time.sleep(1)
        print("asdf")
        return Response("pong")
