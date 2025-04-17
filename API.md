## images

### Creating an image

```bash
curl -F picture[image]=@pLDPqfwoVpo.jpg -F picture[type]=Icon -F picture[description]="опис" -F picture[language]=ру -F picture[alphabeth]=РУ --insecure https://dneslov.org/api/v1/images/create.json
```

```json
{"uid":"ca05594b-948e-4d05-80d8-a58f21793ae0","type":"Icon","width":2560,"height":1707,"meta":{},"language":"ру","alphabeth":"РУ","title":null,"description":"опис","thumb_url":"https://dneslov.org/images/thumb_ca05594b-948e-4d05-80d8-a58f21793ae0.webp","url":"https://localhost:33333/images/ca05594b-948e-4d05-80d8-a58f21793ae0.webp","attitudes":[]}
```

### Reading image properties

```bash
curl  --insecure https://dneslov.org/api/v1/images/ca05594b-948e-4d05-80d8-a58f21793ae0.json
```

```json
{"uid":"ca05594b-948e-4d05-80d8-a58f21793ae0","type":"Icon","width":2560,"height":1707,"meta":{},"language":"ру","alphabeth":"ру","title":null,"description":null,"thumb_url":"https://dneslov.org/images/thumb_ca05594b-948e-4d05-80d8-a58f21793ae0.webp","url":"https://localhost:33333/images/ca05594b-948e-4d05-80d8-a58f21793ae0.webp","attitudes":[]}
```

Send new image

```
curl --insecure -F picture[language]=ру -F picture[alphabeth]=РУ -F picture[type]=Icon  -F picture[attitude_to]="Акепсим Наессонский" -F picture[title]="Сщмч. Акепсимъ Наессонскій. Фреска 14-го вѣка Саѵѵинской церкви въ Сапарской обители въ Грузіи. Кругляшъ" -F picture[description]="Священномученикъ Акепсимъ Наессонскій. Фреска 14-го вѣка Саѵѵинской церкви въ Сапарской обители въ Грузіи. Кругляшъ" -F picture[image]=@1.webp dneslov.org/api/v1/images/create.json
```

Send roundel
```
curl --insecure -F roundel[roundelable_name]="Акепсим Наессонский" -F roundel[image]=@r.webp https://dneslov.org/api/v1/roundels/create.json
```

### audios

#### create an audio resource
```
curl --insecure -X POST -F audio[kind]=Troparion -F audio[title]="Тропарь Петру и Павлу" -F audio[description]="Тропарь первоверховным Петру и Павлу почитания их ради" -F audio[language]=ру -F audio[alphabeth]=РО -F audio[audio]=@5.mp3 -F audio[attitude_to]="кама#10104(1.1,1.2)" -F audio[reading]="Апостолов первопрестольницы" https://dneslov.org/api/v0/audios/create.json -v
```

### show to get the audio resource
```
curl --insecure -X GET https://dneslov.org/api/v0/audios/c92804e2010143afb8cca69b15594f3b.json
```

#### index audio resources
```
curl --insecure -X GET https://dneslov.org/api/v0/audios.json
```

#### delete the audio resource
```
curl --insecure -X DELETE https://dneslov.org/api/v0/audios/833675050afe4ad2a96e355f05f91268.json
```


### rites

#### create an rite resource
```
curl --insecure -X POST -F rite[bind_kind_rite]=несвязан -F rite[abbreviation]="аббрв" -F rite[text]="текст" -F rite[language_code]=ру -F rite[alphabeth_code]=РО -F rite[title]="Титуло" -F rite[description]="Дане" https://dneslov.org/api/v0/rites/create.json -v
```

### show to get the rite resource
```
curl --insecure -X GET https://dneslov.org/api/v0/rites/1.json
```

#### index rite resources
```
curl --insecure -X GET https://dneslov.org/api/v0/rites.json
```

#### delete the rite resource
```
curl --insecure -X DELETE https://dneslov.org/api/v0/rites/1.json
```


