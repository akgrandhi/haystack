# Elasticsearch deployment itself
apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  name: ${elasticsearch-name}
  namespace: kube-system
  labels:
    k8s-app: ${elasticsearch-name}
    version: v5.6.5
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
spec:
  serviceName: ${elasticsearch-name}
  replicas: 1
  selector:
    matchLabels:
      k8s-app: ${elasticsearch-name}
      version: v5.6.5
  template:
    metadata:
      labels:
        k8s-app: ${elasticsearch-name}
        version: v5.6.5
        kubernetes.io/cluster-service: "true"
    spec:
      containers:
      - image: docker.elastic.co/elasticsearch/elasticsearch:5.6.5
        name: ${elasticsearch-name}
        resources:
          # need more cpu upon initialization, therefore burstable class
          limits:
            cpu: 1000m
          requests:
            cpu: 100m
        ports:
        - containerPort: 9200
          name: db
          protocol: TCP
        - containerPort: 9300
          name: transport
          protocol: TCP
        volumeMounts:
        - name: ${elasticsearch-name}
          mountPath: /data
        env:
        - name: "ES_JAVA_OPTS"
          value: "-Xms256m -Xmx256m"
        - name: "XPACK_SECURITY_ENABLED"
          value: "false"
      initContainers:
      - image: alpine:3.6
        command: ["/sbin/sysctl", "-w", "vm.max_map_count=262144"]
        name: ${elasticsearch-name}-init
        securityContext:
          privileged: true
  volumeClaimTemplates:
    - metadata:
        name: ${elasticsearch-name}
        annotations:
          volume.beta.kubernetes.io/storage-class: "standard"
      spec:
        storageClassName: "standard"
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 100Mi


---
apiVersion: v1
kind: Service
metadata:
  name: ${elasticsearch-name}
  namespace: kube-system
  labels:
    k8s-app: ${elasticsearch-name}
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
    kubernetes.io/name: "Elasticsearch"
spec:
  ports:
  - port: 9200
    protocol: TCP
    targetPort: db
  selector:
    k8s-app: ${elasticsearch-name}
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: kibana-logging
  namespace: kube-system
  labels:
    k8s-app: kibana-logging
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
spec:
  replicas: 1
  selector:
    matchLabels:
      k8s-app: kibana-logging
  template:
    metadata:
      labels:
        k8s-app: kibana-logging
    spec:
      containers:
      - name: kibana-logging
        image: docker.elastic.co/kibana/kibana:5.6.5
        resources:
          # need more cpu upon initialization, therefore burstable class
          limits:
            cpu: 1000m
          requests:
            cpu: 100m
        env:
          - name: ELASTICSEARCH_URL
            value: http://${elasticsearch-name}:9200
          - name: SERVER_BASEPATH
            value: /logs
          - name: XPACK_MONITORING_ENABLED
            value: "false"
          - name: XPACK_SECURITY_ENABLED
            value: "false"
        ports:
        - containerPort: 5601
          name: ui
          protocol: TCP
---
apiVersion: v1
kind: Service
metadata:
  name: kibana-logging
  namespace: kube-system
  labels:
    k8s-app: kibana-logging
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
    kubernetes.io/name: "Kibana"
spec:
  ports:
  - port: 5601
    protocol: TCP
    targetPort: ui
  selector:
    k8s-app: kibana-logging

