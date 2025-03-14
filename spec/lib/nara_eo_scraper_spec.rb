require "spec_helper"


describe NaraEoScraper do
  it "in conflicts between anchor tag 'name' attribute metadata text displayed, prioritize displaying what is visibly shown to the user" do
    html = <<-HTML
      <p><strong>Executive Order     <a name="86497"></a>8697 </strong>
      <br>Transfer of Certain Lands From the Secretary of the Interior to the Secretary of Agriculture; New Mexico </p>
      <ul><li>Signed: February 28, 1941</li>
      <li>Federal Register page and date: 6 FR 1230, March 4, 1941 </li>
      </ul>
    HTML
    
    result = described_class.eo_metadata(html, 'arbitrary_president', 'arbitrary_url')

    expect(result[0].first).to eq("8697")
  end

  it "handles scenarios where there are multiple EOs not separated by an HR" do
    html = <<-HTML
      <hr>
      <p><strong>Executive Order   <a name="7800"></a>7800</strong>
      <br>Transferring Certain Lands to the Control and Jurisdiction of the Secretary of the Navy, Cuba</p>
      <ul><li>Signed: January 27, 1938</li>
      <li>Federal Register page and date: 3 FR 262, January 29, 1938</li>
      <li>Amends: Executive Order of January 9, 1904 (unnumbered series) </li>
      </ul>
      
      <p><strong>Executive Order No. <a name="7801"></a> 7801 </strong>
      <br>Establishing Black Coulee Migratory Waterfowl Refuge, Montana</p>
      <ul><li>Signed: January 28, 1938 </li>
      <li>Federal Register page and date: 3 FR 271, February 1, 1938</li>
      </ul>
    HTML
    
    result = described_class.eo_metadata(html, 'arbitrary_president', 'arbitrary_url')
   
    expect(result.count).to eq(2)
    expect(result[0].first).to eq("7800")
    expect(result[1].first).to eq("7801")
  end

  it "correctly parses EO number even when there is a PDF link" do
    html = <<-HTML
      <hr>



      <p>

        <a name="0.1_13717"></a>
      <strong>
      
        <a class="pdfImage" href="https://www.gpo.gov/fdsys/pkg/FR-2016-02-05/pdf/2016-02475.pdf">Executive Order 13717</a></strong>
      <br>
        
      Establishing a Federal Earthquake Risk Management Standard</p>


      <ul>


        <li>Signed: February 2, 2016</li>


        <li>Federal Register page and date: 81 FR 6407, February 5, 2016</li>


        <li>Revokes: 
      
          <a href="/federal-register/executive-orders/1990.html#12699">EO 12699</a>, January 5, 1990; 
      
          <a href="/federal-register/executive-orders/1994.html#12941">EO 12941</a>, December 1, 1994</li>

      </ul>
    HTML
    result = described_class.eo_metadata(html, 'arbitrary_president', 'arbitrary_url')
    expect(result.first[0]).to eq('13717')
  end

  it "strips leading/trailing whitespace from EO title" do
    html =  <<-HTML
      <hr>


      <p>
        <a name="13423"></a>
      <strong>
        <a class="pdfImage" href="http://www.gpo.gov/fdsys/pkg/FR-2007-01-26/pdf/07-374.pdf">Executive Order 13423</a></strong>
      <br>
        Strengthening Federal Environmental, Energy, and Transportation Management</p>

      <ul>

        <li>Signed: January 24, 2007</li>

        <li>Federal Register page and date: 72 FR 3919, January 26, 2007</li>

        <li>Amends: 
          <a href="/federal-register/executive-orders/2004.html#13327">EO 13327</a>, February 4, 2004</li>

        <li>Revokes: 
          <a href="/federal-register/executive-orders/1998.html#13101">EO 13101</a>, September 14, 1998; 
          <a href="/federal-register/executive-orders/1999.html#13123">EO 13123</a>, June 3, 1999; 
          <a href="/federal-register/executive-orders/1999.html#13134">EO 13134</a>, August 12, 1999; 
          <a href="/federal-register/executive-orders/2000.html#13148">EO 13148</a>, April 21, 2000; 
          <a href="/federal-register/executive-orders/2000.html#13149">EO 13149</a>, April 21, 2000</li>

        <li>See: 
          <a href="/federal-register/executive-orders/2007.html#13432">EO 13432</a>, May 14, 2007; 
          <a href="/federal-register/executive-orders/2009-obama.html#13514">EO 13514</a>, October 5, 2009</li>

        <li>Revoked by: 
          <a href="/federal-register/executive-orders/2015.html#13693">EO 13693</a>, March 25, 2015</li>


      </ul>
    HTML

    result = described_class.eo_metadata(html, 'arbitrary_president', 'arbitrary_url')
    expect(result.first[1]).to eq('Strengthening Federal Environmental, Energy, and Transportation Management')
  end

  it "does not include the EO number in the title for Kennedy era EOs" do
    html =  <<-HTML
      <hr>






      <p><strong>Executive Order 
        <a name="10984"></a>10984</strong>

      <br>
        Amending the Selective Service Regulations</p>


      <ul>


        <li>Signed: January 5, 1962</li>


        <li>Federal Register page and date: 27 FR 193, January 9, 1962</li>


        <li>Amends: 
          <a href="/federal-register/executive-orders/1948.html#9988">EO 9988</a>, August 20, 1948; 
          <a href="/federal-register/executive-orders/1948.html#10001">EO

      10001</a>, September 17, 1948; 
          <a href="/federal-register/executive-orders/1948.html#10008">EO 10008</a>, October

      18, 1948; 
          <a href="/federal-register/executive-orders/1950.html#10116">EO 10116</a>, March 9, 1950; 
          <a href="/federal-register/executive-orders/1951.html#10202">EO

      10202</a>, January 12, 1951; 
          <a href="/federal-register/executive-orders/1951.html#10292">EO 10292</a>, September

      25, 1951; 
          <a href="/federal-register/executive-orders/1952.html#10328">EO 10328</a>, February 20, 1952; 
          <a href="/federal-register/executive-orders/1952.html#10363">EO

      10363</a>, June 17, 1952; 
          <a href="/federal-register/executive-orders/1954.html#10562">EO 10562</a>, September

      20, 1954; 
          <a href="/federal-register/executive-orders/1955.html#10594">EO 10594</a>, January 31, 1955; 
          <a href="/federal-register/executive-orders/1956.html#10650">EO

      10650</a>, January 6, 1956; 
          <a href="/federal-register/executive-orders/1956.html#10659">EO 10659</a>, February

      15, 1956; 
          <a href="/federal-register/executive-orders/1957.html#10714">EO 10714</a>, June 13, 1957; 
          <a href="/federal-register/executive-orders/1957.html#10735">EO

      10735</a>, October 17, 1957; 
          <a href="/federal-register/executive-orders/1959.html#10809">EO 10809</a>, March

      19, 1959</li>


        <li>Amended by: 
          <a href="/federal-register/executive-orders/1963-kennedy.html#11098">EO 11098</a>, March 14,

      1963; 
          <a href="/federal-register/executive-orders/1963-kennedy.html#11119">EO 11119</a>, September 10, 1963;

      
          <a href="/federal-register/executive-orders/1964.html#11188">EO 11188</a>, November 17, 1964; 
          <a href="/federal-register/executive-orders/1965.html#11241">EO

      11241</a>, August 26, 1965; 
          <a href="/federal-register/executive-orders/1967.html#11350">EO 11350</a>, May

      3, 1967; 
          <a href="/federal-register/executive-orders/1967.html#11360">EO 11360</a>, June 30, 1967; 
          <a href="/federal-register/executive-orders/1969-nixon.html#11497">EO

      11497</a>, November 26, 1969; 
          <a href="/federal-register/executive-orders/1970.html#11527">EO 11527</a>, April

      23, 1970; 
          <a href="/federal-register/executive-orders/1970.html#11537">EO 11537</a>, June 16, 1970; 
          <a href="/federal-register/executive-orders/1970.html#11563">EO

      11563</a>, September 26, 1970; 
          <a href="/federal-register/executive-orders/1971.html#11586">EO 11586</a>, March

      10, 1971</li>


        <li>Revoked by: 
          <a href="/federal-register/executive-orders/1986.html#12553">EO 12553</a>, February 25, 1986</li>


      </ul>
    HTML

    result = described_class.eo_metadata(html, 'arbitrary_president', 'arbitrary_url')
    expect(result.first[1]).to eq('Amending the Selective Service Regulations')
    expect(result.first[2]).to eq('27 FR 193')
    expect(result.first[0]).to eq('10984')
  end

  it "does not include the EO number in the title for Carter era EOs" do
    html =  <<-HTML
  <hr>
    <p><strong>Executive Order 
	<a name="12123"></a>12123</strong>

<br>
	Offshore oil spill pollution</p>
    HTML

    result = described_class.eo_metadata(html, 'arbitrary_president', 'arbitrary_url')
    expect(result.first[1]).to eq('Offshore oil spill pollution')
  end

  it "Handle '¬†' characters in some Bush-era docs" do
    html =  <<-HTML
    <hr>
    <p><a name="13283"></a> <strong> <a class="pdfImage" href="http://www.gpo.gov/fdsys/pkg/FR-2003-01-24/pdf/03-1798.pdf">Executive Order 13283</a></strong><br>
  Establishing the Office of Global Communications</p>
    <ul>
      <li>Signed: &nbsp; January 21, 2003</li>
      <li>Federal Register page and date: &nbsp; 68 FR 3371, January 24, 2003</li>
      <li>See: &nbsp; <a href="/federal-register/executive-orders/1981-reagan.html#12333">EO 12333</a>, December 4, 1981</li>
      <li>Revoked by: <a href="/federal-register/executive-orders/2005.html#13385">EO 13385</a>, September 29, 2005</li>
    </ul>
    HTML
  
    result = described_class.eo_metadata(html, 'arbitrary_president', 'arbitrary_url')
    expect(result.first[2]).to eq('68 FR 3371')
  end

  it "Handles citation lines not prefixed by 'Federal Register page and date:' (eg some FDR citations)" do
    html =  <<-HTML
      <hr>
      <p><strong>Executive Order     <a name="9526"></a>9526</strong>
      <br>Amending Certain Executive and Public Land Orders Withdrawing Public Lands for Purposes Incident to the National Emergency and Prosecution of the War</p>
      <ul><li>Signed: February 28, 1945 </li>
        <li>10 FR 2423, March 2, 1945</li>
        <li>Amends: <a href="/federal-register/executive-orders/1939.html#8101">EO 8101</a>, April 28, 1939; <a href="/federal-register/executive-orders/1939.html#8102">EO 
              8102</a>, April 29, 1939; <a href="/federal-register/executive-orders/1939.html#8305">EO 8305</a>, December 
              19, 1939; <a href="/federal-register/executive-orders/1940.html#8325">EO 8325</a>, January 22, 1940; <a href="/federal-register/executive-orders/1940.html#8343">EO 
              8343</a>, February 10, 1940; <a href="/federal-register/executive-orders/1940.html#8450">EO 8450</a>, June 
              20, 1940; <a href="/federal-register/executive-orders/1940.html#8507">EO 8507</a>, August 8, 1940; <a href="/federal-register/executive-orders/1940.html#8508">EO 
              8508</a>, August 8, 1940; <a href="/federal-register/executive-orders/1940.html#8577">EO 8577</a>, October 
              29, 1940; <a href="/federal-register/executive-orders/1940.html#8578">EO 8578</a>, October 29, 1940; <a href="/federal-register/executive-orders/1940.html#8579">EO 
              8579</a>, October 29, 1940; <a href="/federal-register/executive-orders/1941.html#8636">EO 8636</a>, January 
              14, 1941; <a href="/federal-register/executive-orders/1941.html#8651">EO 8651</a>, January 23, 1941; <a href="/federal-register/executive-orders/1941.html#8652">EO 
              8652</a>, January 28, 1941; <a href="/federal-register/executive-orders/1941.html#8725">EO 8725</a>, March 
              29, 1941; <a href="/federal-register/executive-orders/1941.html#8755">EO 8755</a>, May 16, 1941; <a href="/federal-register/executive-orders/1941.html#8788">EO 
              8788</a>, June 14, 1941; <a href="/federal-register/executive-orders/1941.html#8789">EO 8789</a>, June 14, 
              1941; <a href="/federal-register/executive-orders/1941.html#8792">EO 8792</a>, June 14, 1941; <a href="/federal-register/executive-orders/1941.html#8793">EO 
              8793</a>, June</li>
        <li>Revoked by: Public Land Order 341, January 13, 1947 (12 FR 417) (in part); Public Land Order 342, January 13, 1947 (12 FR 418) (in part); Public Land Order 354, February 19, 1947 (12 FR 1445) (in part)</li>
      </ul>
    HTML

    result = described_class.eo_metadata(html, 'roosevelt', 'arbitrary_url')
    expect(result.first[2]).to eq('10 FR 2423')

    #It correctly maps NARA identifier to API Core style president identifier
    expect(result.first[7]).to eq('franklin-d-roosevelt')
  end

  it "can handle citations where the publication date errantly comes first that end with a comma" do
    html =  <<-HTML
      <p><strong>Executive Order    <a name="8605"></a>8605 </strong>
      <br> Ordering Certain Units and Members of the National Guard of the United States Into the Active Military Service of the United States</p>
      <ul><li>Signed: November 30, 1940 </li>
        <li>Federal Register page and date: December 5, 1940 5 FR 4795, </li>
      </ul>
    HTML

    result = described_class.eo_metadata(html, 'roosevelt', 'arbitrary_url')
    expect(result.first[2]).to eq('5 FR 4795')
  end

  it "can handle citations where the publication date errantly comes first" do
    html =  <<-HTML
      <p>
        <strong>Executive Order     <a name="8874"></a>8874  </strong>
        <br> Withdrawing Public Lands for Use of the War Department as a Practice Bombing Range; New Mexico 
      </p>
      <ul><li>Signed: August 28, 1941 </li>
        <li>Federal Register page and date: August 30, 1941, 6 FR 4485</li>
        <li>Amended by: <a href="/federal-register/executive-orders/1945-roosevelt.html#9526">EO 9526</a>, February 28, 
              1945 </li>
        <li>Revoked by: Public Land Order 496, July 9, 1948 (13 FR 4126)(in part); Public Land Order 682, November 3, 1950 (15 FR 7645)(in part); Public Land Order 2807, October 25, 1962 (27 FR 10583) </li>
        <li>See: <!--A href="eo1934.html#6910"-->EO 6910, November 26, 1934 </li>
      </ul>
    HTML

    result = described_class.eo_metadata(html, 'roosevelt', 'arbitrary_url')
    expect(result.first[2]).to eq('6 FR 4485')
  end

  it "can distinguish between citation and publication date even when no comma is present" do
    html =  <<-HTML
      <p><strong>Executive Order    <a name="9918"></a>9918</strong>
      <br>  Creating an Emergency Board To Investigate Disputes Between the Alabama, Tennessee and Northern Railroad Company and Other Carriers, and Certain of Their Employees</p>
      <ul><li>Signed: December 31, 1947 </li>
      <li>Federal Register Page and Date: 13 FR 27 January 3, 1948  </li>
      <li> Revoked by: <a href="/federal-register/executive-orders/1986.html#12553">EO 12553</a>, February 25, 1986</li>
      </ul>
    HTML

    result = described_class.eo_metadata(html, 'roosevelt', 'arbitrary_url')
    expect(result.first[2]).to eq('13 FR 27')
    expect(result.first[6]).to eq('1948-01-03')
  end

  it "removes superfluous EO number that precedes a title if it comes first" do #eg '12334\n\n \n \n Example Title'
    html =  <<-HTML
      <p><strong>Executive Order 
      
        <a name="12334"></a>12334</strong>

      <br>
        
      President's Intelligence Oversight Board</p>
    HTML

    result = described_class.eo_metadata(html, 'roosevelt', 'arbitrary_url')
    expect(result.first[1]).to eq("President's Intelligence Oversight Board")
  end

end
