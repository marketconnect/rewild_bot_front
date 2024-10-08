run:
	go run app/cmd/main.go

git:
	git add .
	git commit -a -m "$m"
	git push -u origin main

gen:
	protoc -I=app/proto --go_out=app/gen/ app/proto/*.proto
	protoc --go-grpc_out=app/gen/ app/proto/*.proto -I=app/proto
	protoc --dart_out=grpc:../big_brother/lib/pb/ -Iapp/proto app/proto/*.proto

migrate_up:
	migrate -path ./schema -database 'postgres://postgres:postgres@localhost:5432/mc_db?sslmode=disable' up

migrate_down:
	migrate -path ./schema -database 'postgres://postgres:postgres@localhost:5432/mc_db?sslmode=disable' down

build:
	rm mc
	GOOS=linux GOARCH=amd64 go build -o mc app/cmd/main.go

